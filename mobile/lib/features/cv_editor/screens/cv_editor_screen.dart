import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/widgets/frosted_app_bar.dart';
import '../../job_matcher/screens/job_matcher_screen.dart';
import '../../pdf_engine/pdf_generator.dart';
import '../../pdf_engine/pdf_preview_screen.dart';
import '../models/cv_model.dart';
import '../services/cv_profile_manager.dart';
import '../widgets/ats_plain_text_dialog.dart';
import '../widgets/certifications_section.dart';
import '../widgets/daily_quota_banner.dart';
import '../widgets/editor_bottom_bar.dart';
import '../widgets/education_section.dart';
import '../widgets/executive_summary_section.dart';
import '../widgets/job_matcher_banner.dart';
import '../widgets/personal_info_section.dart';
import '../widgets/profile_switcher_bar.dart';
import '../widgets/skills_section.dart';
import '../widgets/template_selector_card.dart';
import '../widgets/work_experience_section.dart';

/// Clean Orchestrator for CV Editor & Multi-Profile Switcher (3 Variations)
/// Adheres 100% to UI UX Pro Max, Quiet Luxury, and Anti-Spaghetti Architecture
class CvEditorScreen extends StatefulWidget {
  const CvEditorScreen({super.key});

  @override
  State<CvEditorScreen> createState() => _CvEditorScreenState();
}

class _CvEditorScreenState extends State<CvEditorScreen> {
  final _profileMgr = CvProfileManager.instance;
  late CvDocument _cv;
  int _remainingQuota = 5;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _summaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cv = _profileMgr.currentCv.clone();
    _syncControllersFromModel();
    _profileMgr.addListener(_onProfileMgrUpdate);
    _initManager();
  }

  Future<void> _initManager() async {
    await _profileMgr.init();
    if (mounted) {
      setState(() {
        _cv = _profileMgr.currentCv.clone();
        _syncControllersFromModel();
      });
    }
    _fetchQuota();
  }

  void _onProfileMgrUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _profileMgr.removeListener(_onProfileMgrUpdate);
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _syncControllersFromModel() {
    _nameController.text = _cv.personalInfo.fullName;
    _titleController.text = _cv.personalInfo.professionalTitle;
    _emailController.text = _cv.personalInfo.email;
    _phoneController.text = _cv.personalInfo.phone;
    _locationController.text = _cv.personalInfo.location;
    _linkedinController.text = _cv.personalInfo.linkedin;
    _summaryController.text = _cv.summary;
  }

  void _syncModelFromControllers() {
    _cv.personalInfo.fullName = _nameController.text;
    _cv.personalInfo.professionalTitle = _titleController.text;
    _cv.personalInfo.email = _emailController.text;
    _cv.personalInfo.phone = _phoneController.text;
    _cv.personalInfo.location = _locationController.text;
    _cv.personalInfo.linkedin = _linkedinController.text;
    _cv.summary = _summaryController.text;
  }

  /// Blueprint Bagian 10: Validasi Pra-Generate AI (Filter Kelayakan Data)
  bool get _isEligibleForAi {
    final hasName = _nameController.text.trim().isNotEmpty;
    final hasContact = _emailController.text.trim().isNotEmpty || _phoneController.text.trim().isNotEmpty;
    final hasHistory = _cv.experiences.isNotEmpty || _cv.educations.isNotEmpty;
    final hasSkills = _cv.skills.length >= 3;
    return hasName && hasContact && hasHistory && hasSkills;
  }

  Future<void> _fetchQuota() async {
    try {
      final quotaData = await ApiService.instance.getQuota();
      if (quotaData['success'] == true && mounted) {
        setState(() => _remainingQuota = quotaData['quota']['remaining'] ?? 5);
      }
    } catch (_) {}
  }

  Future<void> _handleProfileSwitch(int newIndex) async {
    _syncModelFromControllers();
    await _profileMgr.switchProfile(newIndex, currentDraft: _cv);
    setState(() {
      _cv = _profileMgr.currentCv.clone();
      _syncControllersFromModel();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.switched'.trArgs(['$newIndex'])),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.midnightNavy,
        ),
      );
    }
  }

  void _handleRenameProfile(String newTitle, String newTargetJob) {
    _profileMgr.updateProfileMeta(
      _profileMgr.currentIndex,
      title: newTitle.isNotEmpty ? newTitle : null,
      targetJob: newTargetJob.isNotEmpty ? newTargetJob : null,
    );
  }

  Future<void> _handleGenerateAi() async {
    if (!_isEligibleForAi) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('validation.core_fields_missing'.tr)),
      );
      return;
    }

    if (_remainingQuota <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('quota.limit_reached'.tr)),
      );
      return;
    }

    await AdService.instance.showRewardedAd(
      context: context,
      prompt: 'ad.reward_prompt_generate'.tr,
      onRewarded: _executeGenerateAi,
    );
  }

  Future<void> _executeGenerateAi() async {
    _syncModelFromControllers();
    setState(() => _isLoading = true);

    try {
      final payload = {
        'full_name': _cv.personalInfo.fullName,
        'professional_title': _cv.personalInfo.professionalTitle,
        'contact': {
          'email': _cv.personalInfo.email,
          'phone': _cv.personalInfo.phone,
          'location': _cv.personalInfo.location,
        },
        'summary': _cv.summary,
        'experiences': _cv.experiences.map((e) => e.toJson()).toList(),
        'educations': _cv.educations.map((e) => e.toJson()).toList(),
        'skills': _cv.skills,
        'certifications': _cv.certifications,
      };

      final response = await ApiService.instance.generateCv(payload);
      if (response['success'] == true && mounted) {
        final data = response['cv_data'];
        final List<String> changesApplied = [];

        // Apply improved summary
        if (data['summary'] != null && (data['summary'] as String).isNotEmpty) {
          _cv.summary = data['summary'];
          _summaryController.text = data['summary'];
          changesApplied.add('Summary');
        }

        // Apply improved experiences (bullet_points / highlights)
        if (data['experiences'] != null && (data['experiences'] as List).isNotEmpty) {
          final expList = data['experiences'] as List;
          for (int i = 0; i < expList.length && i < _cv.experiences.length; i++) {
            final expItem = expList[i] as Map<String, dynamic>;
            // Update bullet_points / highlights
            if (expItem['bullet_points'] != null && (expItem['bullet_points'] as List).isNotEmpty) {
              _cv.experiences[i].highlights = List<String>.from(expItem['bullet_points']);
            } else if (expItem['highlights'] != null && (expItem['highlights'] as List).isNotEmpty) {
              _cv.experiences[i].highlights = List<String>.from(expItem['highlights']);
            }
            // Update position/title if improved
            if (expItem['position'] != null && (expItem['position'] as String).isNotEmpty) {
              _cv.experiences[i].position = expItem['position'];
            }
          }
          changesApplied.add('Work Experience');
        }

        // Apply improved skills
        if (data['skills'] != null && (data['skills'] as List).isNotEmpty) {
          _cv.skills = List<String>.from(data['skills']);
          changesApplied.add('Skills');
        }

        // Apply improved educations if present
        if (data['educations'] != null && (data['educations'] as List).isNotEmpty) {
          final eduList = data['educations'] as List;
          for (int i = 0; i < eduList.length && i < _cv.educations.length; i++) {
            final eduItem = eduList[i] as Map<String, dynamic>;
            if (eduItem['degree'] != null && (eduItem['degree'] as String).isNotEmpty) {
              _cv.educations[i].degree = eduItem['degree'];
            }
            if (eduItem['field_of_study'] != null && (eduItem['field_of_study'] as String).isNotEmpty) {
              _cv.educations[i].fieldOfStudy = eduItem['field_of_study'];
            }
          }
          changesApplied.add('Education');
        }

        // Apply improved certifications if present
        if (data['certifications'] != null && (data['certifications'] as List).isNotEmpty) {
          _cv.certifications = List<String>.from(data['certifications']);
          changesApplied.add('Certifications');
        }

        // Update quota
        if (response['quota']?['remaining'] != null) {
          _remainingQuota = response['quota']['remaining'];
        }

        await _profileMgr.saveCurrentProfile(_cv);

        // Refresh all controllers from the updated model
        _syncControllersFromModel();

        if (mounted) {
          final changesSummary = changesApplied.isNotEmpty
              ? changesApplied.join(', ')
              : 'Summary';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('CV berhasil dipoles AI! Bagian yang diperbaiki: $changesSummary'),
            backgroundColor: AppColors.forestPine,
            duration: const Duration(seconds: 3),
          ));
          setState(() {});
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'common.error'.tr)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${'common.error'.tr}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleExportPdf() async {
    if (!mounted) return;
    await AdService.instance.showRewardedAd(
      context: context,
      prompt: 'ad.reward_prompt_download'.tr,
      onRewarded: _executeExportPdf,
    );
  }

  Future<void> _executeExportPdf() async {
    _syncModelFromControllers();

    if (!mounted) return;
    final cv = _cv;
    await PdfPreviewScreen.open(
      context,
      pdfBuilder: () => PdfGenerator.generatePdf(cv),
      fileName: '${cv.personalInfo.fullName}_Resume.pdf',
    );
  }

  void _openJobMatcher() {
    _syncModelFromControllers();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => JobMatcherScreen(
          currentCv: _cv,
          onCvUpdated: (updatedCv) {
            setState(() {
              _cv = updatedCv.clone();
              _syncControllersFromModel();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oysterCanvas,
      appBar: FrostedAppBar(
        title: 'form.title'.tr,
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () {
              _syncModelFromControllers();
              AtsPlainTextDialog.show(context, _cv.toPlainText());
            },
            icon: const Icon(Icons.terminal_rounded, color: AppColors.midnightNavy),
            tooltip: 'Mode Robot ATS',
          ),
          IconButton(
            onPressed: () {
              _syncModelFromControllers();
              _profileMgr.saveCurrentProfile(_cv);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil berhasil disimpan'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppColors.forestPine,
                ),
              );
            },
            icon: const Icon(Icons.save_outlined, color: AppColors.midnightNavy),
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        // UI UX Pro Max standard: 110px bottom padding to prevent being obscured by floating action bar
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileSwitcherBar(
              currentIndex: _profileMgr.currentIndex,
              currentMeta: _profileMgr.currentMeta,
              isSyncing: _profileMgr.isSyncing,
              onProfileSelected: _handleProfileSwitch,
              onRenameProfile: _handleRenameProfile,
            ),
            const SizedBox(height: 14),
            DailyQuotaBanner(remainingQuota: _remainingQuota),
            const SizedBox(height: 14),
            JobMatcherBanner(onTap: _openJobMatcher),
            const SizedBox(height: 14),
            TemplateSelectorCard(
              selectedTemplateId: _cv.templateId,
              selectedFont: _cv.fontFamily,
              onTemplateChanged: (val) => setState(() => _cv.templateId = val),
              onFontChanged: (val) => setState(() => _cv.fontFamily = val),
            ),
            const SizedBox(height: 14),
            PersonalInfoSection(
              nameController: _nameController,
              titleController: _titleController,
              emailController: _emailController,
              phoneController: _phoneController,
              locationController: _locationController,
              linkedinController: _linkedinController,
              localPhotoPath: _cv.personalInfo.localPhotoPath,
              showPhotoOption: _cv.templateId == 'asian_ats',
              onPhotoChanged: (path) => setState(() => _cv.personalInfo.localPhotoPath = path),
            ),
            const SizedBox(height: 14),
            ExecutiveSummarySection(
              controller: _summaryController,
              isEnabled: _cv.showSummary,
              onToggle: (val) => setState(() => _cv.showSummary = val),
            ),
            const SizedBox(height: 14),
            WorkExperienceSection(
              experiences: _cv.experiences,
              isEnabled: _cv.showExperience,
              onToggle: (val) => setState(() => _cv.showExperience = val),
              onAddExperience: (exp) => setState(() => _cv.experiences.add(exp)),
              onRemoveExperience: (idx) => setState(() => _cv.experiences.removeAt(idx)),
              onUpdateExperience: (idx, exp) => setState(() => _cv.experiences[idx] = exp),
            ),
            const SizedBox(height: 14),
            EducationSection(
              educations: _cv.educations,
              isEnabled: _cv.showEducation,
              onToggle: (val) => setState(() => _cv.showEducation = val),
              onAddEducation: (edu) => setState(() => _cv.educations.add(edu)),
              onRemoveEducation: (idx) => setState(() => _cv.educations.removeAt(idx)),
            ),
            const SizedBox(height: 14),
            SkillsSection(
              skills: _cv.skills,
              isEnabled: _cv.showSkills,
              onToggle: (val) => setState(() => _cv.showSkills = val),
              onAddSkill: (s) => setState(() => _cv.skills.add(s)),
              onRemoveSkill: (s) => setState(() => _cv.skills.remove(s)),
            ),
            const SizedBox(height: 14),
            CertificationsSection(
              certifications: _cv.certifications,
              isEnabled: _cv.showCertifications,
              onToggle: (val) => setState(() => _cv.showCertifications = val),
              onAddCertification: (c) => setState(() => _cv.certifications.add(c)),
              onRemoveCertification: (c) => setState(() => _cv.certifications.remove(c)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: EditorBottomBar(
        isLoading: _isLoading,
        isEligibleForAi: _isEligibleForAi,
        onAiPolish: _handleGenerateAi,
        onExportPdf: _handleExportPdf,
      ),
    );
  }
}
