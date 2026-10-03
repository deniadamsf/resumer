import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/coin_service.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/coin_dialogs.dart';
import '../../../core/widgets/coin_topup_sheet.dart';
import '../../../core/widgets/frosted_app_bar.dart';
import '../../cv_editor/models/cv_model.dart';
import '../../cv_editor/services/cv_profile_manager.dart';
import '../../cv_editor/widgets/profile_switcher_bar.dart';
import '../models/job_match_model.dart';
import '../widgets/job_image_input_section.dart';
import '../widgets/job_input_toggle_card.dart';
import '../widgets/job_keywords_section.dart';
import '../widgets/job_match_score_gauge.dart';
import '../widgets/job_tailoring_section.dart';
import '../widgets/job_text_input_section.dart';

/// Clean Orchestrator Screen for AI Job Matcher
/// Follows 100% UI UX Pro Max & Quiet Luxury standards
class JobMatcherScreen extends StatefulWidget {
  final CvDocument? currentCv;
  final ValueChanged<CvDocument>? onCvUpdated;
  final bool? showBackButton;

  const JobMatcherScreen({
    super.key,
    this.currentCv,
    this.onCvUpdated,
    this.showBackButton,
  });

  @override
  State<JobMatcherScreen> createState() => _JobMatcherScreenState();
}

class _JobMatcherScreenState extends State<JobMatcherScreen> {
  final _profileMgr = CvProfileManager.instance;
  late CvDocument _cv;
  JobInputMode _mode = JobInputMode.text;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isTailoring = false;
  JobMatchResult? _result;

  @override
  void initState() {
    super.initState();
    _cv = (widget.currentCv ?? _profileMgr.currentCv).clone();
    _profileMgr.addListener(_onProfileUpdate);
    _textController.text = 'job_match.sample_job_text'.tr;
  }

  @override
  void dispose() {
    _profileMgr.removeListener(_onProfileUpdate);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onProfileUpdate() {
    if (!mounted) return;
    setState(() {
      _cv = _profileMgr.currentCv.clone();
    });
  }

  Future<void> _handleStartMatch() async {
    if (!_cv.isEligibleForAi) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ats.incomplete_profile_desc'.tr),
          backgroundColor: AppColors.antiqueBronze,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final text = _textController.text.trim();
    if (_mode == JobInputMode.text && text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('job_match.no_input_error'.tr)),
      );
      return;
    }
    if (_mode == JobInputMode.image && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('job_match.no_input_error'.tr)),
      );
      return;
    }

    // Eksklusif Koin: Fitur Job Matcher memakan 3 Koin (tidak bisa pakai iklan)
    if (!CoinService.instance.hasEnoughCoins(3)) {
      if (mounted) CoinTopupSheet.show(context);
      return;
    }

    final confirmed = await CoinDialogs.showConfirm(
      context: context,
      cost: 3,
      featureName: 'Pencocok CV & Loker (Job Matcher)',
      subtitle: 'Analisis kecocokan dan rekomendasi penyesuaian CV memakan 3 koin.',
    );
    if (!confirmed || !mounted) return;

    await _executeJobMatch();
  }

  Future<void> _executeJobMatch() async {
    setState(() => _isLoading = true);

    try {
      String? base64Image;
      if (_mode == JobInputMode.image && _selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      final response = await ApiService.instance.matchJob(
        _cv.toPlainText(),
        jobText: _mode == JobInputMode.text ? _textController.text.trim() : null,
        jobImageBase64: base64Image,
      );

      if (response['success'] == true && mounted) {
        // Sinkronisasi saldo koin yang telah dipotong backend
        if (response['coins'] != null) {
          final serverCoins = (response['coins'] as num).toInt();
          await CoinService.instance.updateBalance(serverCoins);
        } else {
          await CoinService.instance.deductLocally(3);
        }

        final rawResult = (response['match_result'] ?? response['ats_result'] ?? {}) as Map<String, dynamic>;
        setState(() {
          _result = JobMatchResult.fromJson(rawResult);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              300.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            );
          }
        });
      } else if (mounted) {
        final statusCode = response['statusCode'];
        if (statusCode == 402 || (response['message']?.toString().toLowerCase().contains('koin') ?? false)) {
          CoinTopupSheet.show(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'common.error'.tr)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'common.error'.tr}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _sanitizeSummary(String raw) {
    String s = raw.trim();
    if (s.startsWith('{') && s.endsWith('}')) {
      try {
        final decoded = json.decode(s);
        if (decoded is Map && decoded['summary'] != null) {
          s = decoded['summary'].toString();
        }
      } catch (_) {
        s = s.substring(1, s.length - 1).trim();
      }
    }
    final match = RegExp(r'^"?summary"?\s*:\s*"(.*)"$', dotAll: true).firstMatch(s);
    if (match != null) {
      s = match.group(1) ?? s;
    }
    return s.replaceAll(RegExp(r'[\{\}\[\]]'), '').trim();
  }

  Future<void> _handleTailorCv() async {
    if (_result == null) return;
    setState(() => _isTailoring = true);

    try {
      Map<String, dynamic>? tailoredData = _result!.tailoredCvData;

      // If tailoredCvData is not in memory, fetch it dynamically from backend
      if (tailoredData == null || tailoredData.isEmpty) {
        final res = await ApiService.instance.tailorJobCv(
          cvText: _cv.toPlainText(),
          jobText: _mode == JobInputMode.text ? _textController.text.trim() : null,
          suggestions: _result!.tailoringSuggestions,
          missingKeywords: _result!.missingKeywords,
        );
        if (res['success'] == true && res['tailored_cv_data'] is Map) {
          tailoredData = Map<String, dynamic>.from(res['tailored_cv_data'] as Map);
        }
      }

      final List<String> appliedSections = [];
      final preservedCertifications = List<CertificationItem>.from(_cv.certifications);
      final preservedProjects = List<ProjectItem>.from(_cv.projects);

      if (tailoredData != null && tailoredData.isNotEmpty) {
        // 1. Apply AI Tailored Summary (Natural language, no JSON, no crude appending)
        if (tailoredData['summary'] != null && tailoredData['summary'] is String) {
          final newSummary = _sanitizeSummary(tailoredData['summary'] as String);
          if (newSummary.isNotEmpty) {
            _cv.summary = newSummary;
            _cv.showSummary = true;
            appliedSections.add('form.summary'.tr);
          }
        }

        // 2. Apply AI Tailored Experiences (Google XYZ bullet points with job keywords)
        if (tailoredData['experiences'] != null && tailoredData['experiences'] is List) {
          final expList = tailoredData['experiences'] as List;
          bool expUpdated = false;
          for (int i = 0; i < expList.length && i < _cv.experiences.length; i++) {
            final expItem = expList[i];
            if (expItem is Map && expItem['bullet_points'] != null && expItem['bullet_points'] is List) {
              final bullets = (expItem['bullet_points'] as List)
                  .map((e) => e.toString().trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              if (bullets.isNotEmpty) {
                _cv.experiences[i].highlights = bullets;
                expUpdated = true;
              }
            }
          }
          if (expUpdated) {
            appliedSections.add('form.experience'.tr);
          }
        }

        // 3. Apply AI Tailored Skills (Prioritized high-impact competencies)
        if (tailoredData['skills'] != null && tailoredData['skills'] is List) {
          final rawSkills = tailoredData['skills'] as List;
          final List<SkillItem> parsedSkills = [];
          for (final s in rawSkills) {
            if (s != null) {
              parsedSkills.add(SkillItem.fromJson(s));
            }
          }
          if (parsedSkills.isNotEmpty) {
            _cv.skills = parsedSkills;
            _cv.showSkills = true;
            appliedSections.add('form.skills'.tr);
          }
        }

        // 4. Apply AI Tailored Projects (ONLY if candidate already has projects)
        if (preservedProjects.isNotEmpty &&
            tailoredData['projects'] != null &&
            tailoredData['projects'] is List) {
          final projList = tailoredData['projects'] as List;
          bool projUpdated = false;
          for (int i = 0; i < projList.length && i < _cv.projects.length; i++) {
            final pItem = projList[i];
            if (pItem is Map && pItem['description'] != null) {
              final desc = pItem['description'].toString().trim();
              if (desc.isNotEmpty) {
                _cv.projects[i].description = desc;
                projUpdated = true;
              }
            }
          }
          if (projUpdated) {
            appliedSections.add('form.projects'.tr);
          }
        }
      } else {
        // Fallback: graceful local alignment if offline
        final currentSkillsMap = <String, SkillItem>{};
        for (final s in _cv.skills) {
          currentSkillsMap[s.name.trim().toLowerCase()] = s;
        }

        bool skillAdded = false;
        for (final kw in _result!.missingKeywords) {
          final cleanKw = kw.trim();
          if (cleanKw.isNotEmpty && !currentSkillsMap.containsKey(cleanKw.toLowerCase())) {
            final newSkill = SkillItem(
              name: cleanKw,
              description: 'job_match.tailor_skill_desc'.tr,
            );
            _cv.skills.add(newSkill);
            currentSkillsMap[cleanKw.toLowerCase()] = newSkill;
            skillAdded = true;
          }
        }
        if (skillAdded) appliedSections.add('form.skills'.tr);

        // Safe Summary check - NEVER append JSON or raw braces
        if (_cv.summary.trim().isNotEmpty && _result!.matchedKeywords.isNotEmpty) {
          final topKeywords = _result!.matchedKeywords
              .where((k) => !k.contains('{') && !k.contains('}') && k.length < 30)
              .take(3)
              .join(', ');
          if (topKeywords.isNotEmpty && !_cv.summary.contains(topKeywords)) {
            final addition = 'job_match.tailor_summary_addition'.trArgs([topKeywords]);
            _cv.summary = '${_cv.summary.trim()}$addition';
            appliedSections.add('form.summary'.tr);
          }
        }
      }

      // Preserve data fidelity: if user had no certifications or projects, guarantee empty
      if (preservedCertifications.isEmpty) {
        _cv.certifications = [];
      }
      if (preservedProjects.isEmpty) {
        _cv.projects = [];
      }

      await CvProfileManager.instance.saveCurrentProfile(_cv);
      widget.onCvUpdated?.call(_cv);

      if (mounted) {
        final sectionsText = appliedSections.isNotEmpty
            ? appliedSections.join(', ')
            : 'form.summary'.tr;
        final successMsg = 'job_match.tailor_success_detailed'.trArgs([sectionsText]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: AppColors.forestPine,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'common.error'.tr}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTailoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oysterCanvas,
      appBar: FrostedAppBar(
        title: 'job_match.title'.tr,
        showBackButton: widget.showBackButton ?? (Navigator.canPop(context)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CoinBadge(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileSwitcherBar(
              currentIndex: _profileMgr.currentIndex,
              currentMeta: _profileMgr.currentMeta,
              isSyncing: _profileMgr.isSyncing,
              onProfileSelected: (index) async {
                await _profileMgr.switchProfile(index);
                setState(() {
                  _cv = _profileMgr.currentCv.clone();
                  _result = null;
                });
              },
              onRenameProfile: (newTitle, newTargetJob) {
                _profileMgr.updateProfileMeta(
                  _profileMgr.currentIndex,
                  title: newTitle.isNotEmpty ? newTitle : null,
                  targetJob: newTargetJob.isNotEmpty ? newTargetJob : null,
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'job_match.subtitle'.tr,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),

            // Tab Switcher Pill
            JobInputToggleCard(
              currentMode: _mode,
              onModeChanged: (mode) => setState(() => _mode = mode),
            ),
            const SizedBox(height: 12),

            // Active Input Section
            if (_mode == JobInputMode.text)
              JobTextInputSection(controller: _textController)
            else
              JobImageInputSection(
                selectedImage: _selectedImage,
                onImageSelected: (img) => setState(() => _selectedImage = img),
              ),
            const SizedBox(height: 14),

            // Primary Match CTA Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleStartMatch,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.compare_arrows_rounded, size: 20, color: Colors.white),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLoading ? 'common.loading'.tr : 'job_match.match_btn'.tr,
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    if (!_isLoading) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.toll_rounded, size: 11, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              '3 Koin',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.midnightNavy,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),

            // Results Section (Rendered smoothly when ready)
            if (_result != null) ...[
              const SizedBox(height: 24),
              const Divider(height: 1, color: AppColors.borderHairline),
              const SizedBox(height: 20),
              JobMatchScoreGauge(
                score: _result!.matchScore,
                verdict: _result!.verdict,
              ),
              if (_result!.fitSummary != null && _result!.fitSummary!.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildFitSummaryCard(
                  _result!.fitSummary!.trim(),
                  score: _result!.matchScore,
                ),
              ],
              const SizedBox(height: 20),
              JobKeywordsSection(
                matchedKeywords: _result!.matchedKeywords,
                missingKeywords: _result!.missingKeywords,
              ),
              const SizedBox(height: 16),
              JobTailoringSection(
                suggestions: _result!.tailoringSuggestions,
                onTailorCv: _handleTailorCv,
                isTailoring: _isTailoring,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFitSummaryCard(String summary, {required int score}) {
    final accentColor = score >= 80
        ? AppColors.forestPine
        : (score >= 60 ? AppColors.antiqueBronze : AppColors.crimsonBordeaux);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics_outlined, size: 16, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'job_match.fit_summary_title'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: GoogleFonts.outfit(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
