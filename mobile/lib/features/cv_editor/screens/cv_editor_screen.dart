import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/widgets/frosted_app_bar.dart';
import '../../ats_checker/widgets/ats_report_bottom_sheet.dart';
import '../../cover_letter/widgets/cover_letter_modal.dart';
import '../../job_matcher/screens/job_matcher_screen.dart';
import '../../pdf_engine/pdf_generator.dart';
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
        'contact': {
          'email': _cv.personalInfo.email,
          'phone': _cv.personalInfo.phone,
          'location': _cv.personalInfo.location,
        },
        'experiences': _cv.experiences.map((e) => e.toJson()).toList(),
        'educations': _cv.educations.map((e) => e.toJson()).toList(),
        'skills': _cv.skills,
      };

      final response = await ApiService.instance.generateCv(payload);
      if (response['success'] == true && mounted) {
        final data = response['cv_data'];
        if (data['summary'] != null) {
          _summaryController.text = data['summary'];
          _cv.summary = data['summary'];
        }
        if (response['quota']?['remaining'] != null) {
          _remainingQuota = response['quota']['remaining'];
        }
        await _profileMgr.saveCurrentProfile(_cv);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('common.success'.tr)));
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

  Future<void> _handleAtsCheck() async {
    if (!mounted) return;
    await AdService.instance.showRewardedAd(
      context: context,
      prompt: 'ad.reward_prompt_check'.tr,
      onRewarded: _executeAtsCheck,
    );
  }

  Future<void> _executeAtsCheck() async {
    _syncModelFromControllers();
    setState(() => _isLoading = true);

    try {
      final plainText = _cv.toPlainText();
      final response = await ApiService.instance.checkAtsScore(
        plainText,
        targetRole: _cv.personalInfo.professionalTitle,
      );

      if (response['success'] == true && mounted) {
        final result = response['ats_result'];
        final score = (result['total_score'] as num?)?.toInt() ?? 92;
        await _profileMgr.saveCurrentProfile(_cv, atsScore: score);

        if (!mounted) return;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => AtsReportBottomSheet(
            score: score,
            verdict: result['verdict'],
            breakdown: result['breakdown'],
            feedback: result['actionable_feedback'],
            candidateName: _cv.personalInfo.fullName,
            targetRole: _cv.personalInfo.professionalTitle,
            onAutoFixTap: () {
              Navigator.pop(ctx);
              _handleAutoFix();
            },
          ),
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

  Future<void> _handleAutoFix() async {
    if (_remainingQuota <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('quota.limit_reached'.tr)),
        );
      }
      return;
    }

    if (!mounted) return;
    await AdService.instance.showRewardedAd(
      context: context,
      prompt: 'ad.reward_prompt_autofix'.tr,
      onRewarded: _executeAutoFix,
    );
  }

  Future<void> _executeAutoFix() async {
    _syncModelFromControllers();
    setState(() => _isLoading = true);

    try {
      final plainText = _cv.toPlainText();
      final response = await ApiService.instance.autoFixAts(plainText);

      if (response['success'] == true && mounted) {
        final improved = response['improved_cv'];
        final improvedData = improved?['improved_cv_data'];

        if (improvedData != null) {
          if (improvedData['summary'] != null) {
            _cv.summary = improvedData['summary'];
            _summaryController.text = improvedData['summary'];
          }
          if (improvedData['experiences'] != null && (improvedData['experiences'] as List).isNotEmpty) {
            final expList = improvedData['experiences'] as List;
            for (int i = 0; i < expList.length && i < _cv.experiences.length; i++) {
              final expItem = expList[i];
              if (expItem['bullet_points'] != null) {
                _cv.experiences[i].highlights = List<String>.from(expItem['bullet_points']);
              }
            }
          }
          if (improvedData['skills'] != null && (improvedData['skills'] as List).isNotEmpty) {
            _cv.skills = List<String>.from(improvedData['skills']);
          }
        }

        final newScore = (improved?['estimated_new_score'] as num?)?.toInt() ?? 96;
        if (response['quota']?['remaining'] != null) {
          _remainingQuota = response['quota']['remaining'];
        }

        await _profileMgr.saveCurrentProfile(_cv, atsScore: newScore);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CV berhasil dioptimalkan! Skor ATS melonjak ke $newScore+'),
              backgroundColor: AppColors.forestPine,
            ),
          );
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
    setState(() => _isLoading = true);

    try {
      final pdfBytes = await PdfGenerator.generatePdf(_cv);
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: '${_cv.personalInfo.fullName}_Resume.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  void _handleCoverLetter() {
    _syncModelFromControllers();
    CoverLetterModal.show(
      context,
      _cv,
      profileName: _profileMgr.currentMeta.title,
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
            onPressed: _handleCoverLetter,
            icon: const Icon(Icons.mail_outline_rounded, color: AppColors.midnightNavy),
            tooltip: 'cover_letter.title'.tr,
          ),
          IconButton(
            onPressed: _openJobMatcher,
            icon: const Icon(Icons.work_outline_rounded, color: AppColors.midnightNavy),
            tooltip: 'job_match.title'.tr,
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
        onAtsCheck: _handleAtsCheck,
        onAiPolish: _handleGenerateAi,
        onCoverLetter: _handleCoverLetter,
        onPlainTextSimulation: () {
          _syncModelFromControllers();
          AtsPlainTextDialog.show(context, _cv.toPlainText());
        },
        onExportPdf: _handleExportPdf,
      ),
    );
  }
}
