import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/coin_service.dart';
import '../../../core/services/document_text_extractor_service.dart';
import '../../../core/services/quota_service.dart';
import '../../../core/widgets/frosted_app_bar.dart';
import '../../cv_editor/models/cv_model.dart';
import '../../cv_editor/services/cv_profile_manager.dart';
import '../../cv_editor/widgets/daily_quota_banner.dart';
import '../../cv_editor/widgets/profile_switcher_bar.dart';
import '../../navigation/screens/main_navigation_shell.dart';
import '../../pdf_engine/templates/template_registry.dart';
import '../widgets/ats_breakdown_section.dart';
import '../widgets/ats_feedback_section.dart';
import '../widgets/ats_score_gauge.dart';
import '../widgets/ats_share_card.dart';

/// Full-screen ATS Quality Score Checker Tab
/// Adheres 100% to UI UX Pro Max and Bespoke Executive Standards
class AtsCheckerScreen extends StatefulWidget {
  const AtsCheckerScreen({super.key});

  @override
  State<AtsCheckerScreen> createState() => _AtsCheckerScreenState();
}

class _AtsCheckerScreenState extends State<AtsCheckerScreen> {
  final _profileMgr = CvProfileManager.instance;
  bool _isLoading = false;
  int? _score;
  String? _verdict;
  Map<String, dynamic>? _breakdown;
  Map<String, dynamic>? _keywordAnalysis;
  List<dynamic> _feedback = [];
  String? _uploadedFileName;
  Map<String, dynamic>? _parsedCvData;
  List<String> _mappingNotes = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentProfileAts();
    _profileMgr.addListener(_onProfileUpdate);
    QuotaService.instance.fetchQuota();
    CoinService.instance.refreshBalance();
  }

  void _loadCurrentProfileAts() {
    final meta = _profileMgr.currentMeta;
    setState(() {
      _score = meta.atsScore;
      _verdict = meta.atsVerdict;
      _breakdown = meta.atsBreakdown;
      _feedback = meta.atsFeedback ?? [];
    });
  }

  @override
  void dispose() {
    _profileMgr.removeListener(_onProfileUpdate);
    super.dispose();
  }

  void _onProfileUpdate() {
    if (mounted) {
      _loadCurrentProfileAts();
    }
  }

  void _showIncompleteProfilePrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ats.incomplete_profile_desc'.tr),
        backgroundColor: AppColors.antiqueBronze,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleRunCheck() async {
    final cv = _profileMgr.currentCv;
    if (!cv.isEligibleForAi) {
      _showIncompleteProfilePrompt();
      return;
    }

    await AdService.instance.showRewardedAd(
      context: context,
      prompt: 'ad.reward_prompt_check'.tr,
      actionType: 'ats_check',
      actionDescription: 'Cek Skor ATS',
      coinCost: 1,
      onRewarded: _executeCheck,
    );
  }

  Future<void> _executeCheck() async {
    setState(() => _isLoading = true);
    try {
      final cv = _profileMgr.currentCv;
      final effectiveRole = _profileMgr.currentMeta.targetJob.trim().isNotEmpty
          ? _profileMgr.currentMeta.targetJob.trim()
          : (cv.personalInfo.professionalTitle.trim().isNotEmpty
              ? cv.personalInfo.professionalTitle.trim()
              : null);
      final response = await ApiService.instance.checkAtsScore(
        cv.toPlainText(),
        targetRole: effectiveRole,
      );

      if (response['success'] == true && mounted) {
        final result = response['ats_result'];
        final newScore = (result['total_score'] as num?)?.toInt() ?? 0;
        final newVerdict = result['verdict'] as String? ??
            (newScore >= 85
                ? 'Top 5% ATS Ready'
                : (newScore >= 60 ? 'Skor Menengah' : 'Perlu Optimasi'));
        final newBreakdown = result['breakdown'] != null
            ? Map<String, dynamic>.from(result['breakdown'])
            : null;
        final newKeywords = result['keyword_analysis'] != null
            ? Map<String, dynamic>.from(result['keyword_analysis'])
            : null;
        final newFeedback = result['actionable_feedback'] != null
            ? List<dynamic>.from(result['actionable_feedback'])
            : [];

        setState(() {
          _score = newScore;
          _verdict = newVerdict;
          _breakdown = newBreakdown;
          _keywordAnalysis = newKeywords;
          _feedback = newFeedback;
        });
        await _profileMgr.updateProfileMeta(
          _profileMgr.currentIndex,
          atsScore: newScore,
          atsVerdict: newVerdict,
          atsBreakdown: newBreakdown,
          atsFeedback: newFeedback,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ats.analyzed_success_snack'.trArgs([_score.toString()])),
              backgroundColor: AppColors.forestPine,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'ats.analysis_failed'.tr),
            backgroundColor: AppColors.crimsonBordeaux,
            duration: const Duration(seconds: 4),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUploadDocument() async {
    try {
      final extracted = await DocumentTextExtractorService.instance.pickAndExtractText();
      if (extracted == null) return; // Pengguna membatalkan

      if (!extracted.hasContent) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teks dokumen terlalu pendek atau kosong. Pastikan memilih CV yang valid.'),
              backgroundColor: AppColors.crimsonBordeaux,
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      await AdService.instance.showRewardedAd(
        context: context,
        prompt: 'ad.reward_prompt_check'.tr,
        actionType: 'ats_upload_check',
        actionDescription: 'Analisis Unggah CV (${extracted.fileName})',
        coinCost: 1,
        onRewarded: () => _executeUploadAnalysis(extracted),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membaca berkas: $e'),
            backgroundColor: AppColors.crimsonBordeaux,
          ),
        );
      }
    }
  }

  Future<void> _executeUploadAnalysis(ExtractedDocumentResult doc) async {
    setState(() => _isLoading = true);
    try {
      final effectiveRole = _profileMgr.currentMeta.targetJob.trim().isNotEmpty
          ? _profileMgr.currentMeta.targetJob.trim()
          : null;

      final response = await ApiService.instance.parseExternalCv(
        doc.text,
        targetRole: effectiveRole,
      );

      if (response['success'] == true && mounted) {
        final result = response['result'];
        final newScore = (result['total_score'] as num?)?.toInt() ?? 0;
        final newVerdict = result['verdict'] as String? ?? 'Hasil Analisis Dokumen';
        final newBreakdown = result['breakdown'] != null
            ? Map<String, dynamic>.from(result['breakdown'])
            : null;
        final newKeywords = result['keyword_analysis'] != null
            ? Map<String, dynamic>.from(result['keyword_analysis'])
            : null;
        final newFeedback = result['actionable_feedback'] != null
            ? List<dynamic>.from(result['actionable_feedback'])
            : [];
        final notes = (result['mapping_notes'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [];

        setState(() {
          _score = newScore;
          _verdict = newVerdict;
          _breakdown = newBreakdown;
          _keywordAnalysis = newKeywords;
          _feedback = newFeedback;
          _parsedCvData = result['parsed_cv_data'] is Map
              ? Map<String, dynamic>.from(result['parsed_cv_data'])
              : null;
          _mappingNotes = notes;
          _uploadedFileName = doc.fileName;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dokumen "${doc.fileName}" berhasil dianalisa! Skor ATS: $newScore'),
            backgroundColor: AppColors.forestPine,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal menganalisis dokumen.'),
            backgroundColor: AppColors.crimsonBordeaux,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSlotSelectionModal() {
    if (_parsedCvData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada data CV dari unggah dokumen. Silakan unggah dokumen PDF/DOCX terlebih dahulu.'),
          backgroundColor: AppColors.antiqueBronze,
        ),
      );
      return;
    }

    int selectedSlot = _profileMgr.currentIndex;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.borderHairline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Pilih Slot CV Tujuan',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.midnightNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'CV dari berkas "${_uploadedFileName ?? 'Dokumen'}" telah disesuaikan oleh AI. Pilih slot untuk menaruh dan membuka CV ini di Editor:',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (int slot = 1; slot <= 3; slot++) ...[
                    _buildSlotSelectionTile(
                      slot: slot,
                      isSelected: selectedSlot == slot,
                      onTap: () => setSheetState(() => selectedSlot = slot),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _applyCvToSlot(selectedSlot);
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: Text(
                        'Simpan ke Slot $selectedSlot & Buka Editor',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.midnightNavy,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _applyCvToSlot(int slotIndex) async {
    if (_parsedCvData == null) return;
    setState(() => _isLoading = true);

    try {
      final doc = CvDocument.fromJson(_parsedCvData!);

      // Language proficiency fallback
      for (final lang in doc.languages) {
        if (lang.proficiency.trim().isEmpty) {
          lang.proficiency = 'Professional Working';
        }
      }

      doc.ensureMonthIntegrity(
        isEnglish: AppLocalizations.instance.currentLocale.startsWith('en'),
      );

      final title = doc.personalInfo.professionalTitle.isNotEmpty
          ? doc.personalInfo.professionalTitle
          : 'CV $slotIndex';

      await _profileMgr.saveProfileToSlot(
        slotIndex,
        doc,
        atsScore: _score,
        atsVerdict: _verdict,
        atsBreakdown: _breakdown,
        atsFeedback: _feedback,
        title: title,
        targetJob: doc.personalInfo.professionalTitle,
        switchToThisSlot: true,
      );

      if (mounted) {
        // Switch to Editor Tab (Tab 0) seamlessly!
        MainNavigationShell.switchToTab(0);

        // Show Mapping notes alert if any unmapped sections occurred
        if (_mappingNotes.isNotEmpty) {
          _showMappingNotesDialog(_mappingNotes);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('CV berhasil disimpan ke Slot $slotIndex dan disesuaikan di Editor!'),
              backgroundColor: AppColors.forestPine,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menerapkan CV ke Slot: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSlotSelectionTile({
    required int slot,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final meta = _profileMgr.getMeta(slot);
    final profileCv = _profileMgr.getProfile(slot);
    final hasData = !profileCv.isEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.midnightNavy.withValues(alpha: 0.05)
              : AppColors.subtleSlateTint.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.midnightNavy : AppColors.borderHairline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.midnightNavy : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '$slot',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.midnightNavy,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        meta.title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.midnightNavy,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (slot == _profileMgr.currentIndex)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.forestPine.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Aktif',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forestPine,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasData
                        ? (meta.targetJob.isNotEmpty ? meta.targetJob : profileCv.personalInfo.fullName)
                        : 'Slot Kosong (Belum ada data)',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      color: hasData ? AppColors.textSecondary : AppColors.mutedSteelSlate,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.midnightNavy : AppColors.mutedSteelSlate,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showMappingNotesDialog(List<String> notes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.midnightNavy, size: 22),
            const SizedBox(width: 8),
            Text(
              'Penyesuaian Format ATS',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.midnightNavy,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agar CV Anda lolos uji mesin ATS dan sesuai tata letak Resumer, AI telah merapikan isian berikut:',
              style: GoogleFonts.outfit(fontSize: 12.5, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            for (final note in notes)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        note,
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.midnightNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Tutup', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAutoFix() async {
    final cv = _profileMgr.currentCv;
    if (!cv.isEligibleForAi) {
      _showIncompleteProfilePrompt();
      return;
    }

    final hasQuota = QuotaService.instance.hasRemainingQuota;

    await AdService.instance.showRewardedAd(
      context: context,
      prompt: hasQuota
          ? 'ad.reward_prompt_autofix'.tr
          : 'ad.quota_exhausted_prompt'.tr,
      actionType: 'ats_autofix',
      actionDescription: hasQuota ? '1-Click ATS Auto-Fix' : 'Bypass Kuota ATS Auto-Fix',
      coinCost: 1,
      allowWatchAd: hasQuota,
      onRewarded: () => _executeAutoFix(bypassQuota: !hasQuota),
    );
  }

  Future<void> _executeAutoFix({bool bypassQuota = false}) async {
    setState(() => _isLoading = true);
    try {
      final cv = _profileMgr.currentCv.clone();
      
      // Preserve all user sections that AI Auto-Fix does not optimize
      final preservedLanguages = List<LanguageItem>.from(cv.languages);
      final preservedHobbies = List<String>.from(cv.hobbies);
      final preservedCertifications = List<CertificationItem>.from(cv.certifications);
      final preservedProjects = List<ProjectItem>.from(cv.projects);
      final preservedEducations = List<Education>.from(cv.educations);
      final preservedPersonalInfo = cv.personalInfo;
      final preservedShowLanguages = cv.showLanguages;
      final preservedShowHobbies = cv.showHobbies;
      final preservedShowCertifications = cv.showCertifications;
      final preservedShowProjects = cv.showProjects;

      final response = await ApiService.instance.autoFixAts(
        cv.toPlainText(),
        suggestions: _feedback,
        bypassQuota: bypassQuota,
      );

      if (response['success'] == true && mounted) {
        if (!bypassQuota) {
          if (response['quota'] != null && response['quota']['remaining'] != null) {
            QuotaService.instance.updateQuota((response['quota']['remaining'] as num).toInt());
          } else {
            QuotaService.instance.consumeLocally();
          }
        }
        final improved = response['improved_cv'];
        final improvedData = improved?['improved_cv_data'];

        if (improvedData != null) {
          // 1. Optimize summary
          if (improvedData['summary'] != null && (improvedData['summary'] as String).isNotEmpty) {
            cv.summary = improvedData['summary'];
          }

          // 2. Optimize work experience bullet points
          if (improvedData['experiences'] != null && (improvedData['experiences'] as List).isNotEmpty) {
            final expList = improvedData['experiences'] as List;
            for (int i = 0; i < expList.length && i < cv.experiences.length; i++) {
              final expItem = expList[i];
              if (expItem is Map && expItem['bullet_points'] != null && expItem['bullet_points'] is List) {
                cv.experiences[i].highlights = List<String>.from(expItem['bullet_points']);
              }
            }
          }

          // 3. Optimize skills with industry keywords & descriptive context
          if (improvedData['skills'] != null && (improvedData['skills'] as List).isNotEmpty) {
            final rawSkills = improvedData['skills'] as List;
            final List<SkillItem> parsedSkills = [];
            final Set<String> seenSkillNames = <String>{};
            for (final s in rawSkills) {
              if (s != null) {
                final item = SkillItem.fromJson(s);
                final k = item.name.trim().toLowerCase();
                if (k.isNotEmpty && !seenSkillNames.contains(k)) {
                  seenSkillNames.add(k);
                  parsedSkills.add(item);
                }
              }
            }
            if (parsedSkills.isNotEmpty) {
              cv.skills = parsedSkills;
            }
          }

          // 4. Optimize certifications & licenses (ONLY if user already has certifications)
          // ATURAN MUTLAK USER: "tapi kalo kosong ya jangan diisi"
          if (preservedCertifications.isNotEmpty &&
              improvedData['certifications'] != null &&
              (improvedData['certifications'] as List).isNotEmpty) {
            final rawCerts = improvedData['certifications'] as List;
            for (int i = 0; i < rawCerts.length && i < cv.certifications.length; i++) {
              final certMap = rawCerts[i];
              if (certMap is Map) {
                if (certMap['name'] != null && (certMap['name'] as String).trim().isNotEmpty) {
                  cv.certifications[i].name = certMap['name'].toString().trim();
                }
                if (certMap['issuer'] != null && (certMap['issuer'] as String).trim().isNotEmpty) {
                  cv.certifications[i].issuer = certMap['issuer'].toString().trim();
                }
                if (certMap['year'] != null && (certMap['year'] as String).trim().isNotEmpty) {
                  cv.certifications[i].year = certMap['year'].toString().trim();
                }
                if (certMap['description'] != null && (certMap['description'] as String).trim().isNotEmpty) {
                  cv.certifications[i].description = certMap['description'].toString().trim();
                }
              }
            }
          }

          // 5. Optimize projects & portfolio with AUTOMATIC DEDUPLICATION
          // ATURAN MUTLAK USER: "tapi kalo kosong ya jangan diisi"
          if (preservedProjects.isNotEmpty) {
            final List<ProjectItem> newProjects = [];
            final Set<String> seenProjectNames = <String>{};

            if (improvedData['projects'] != null && (improvedData['projects'] as List).isNotEmpty) {
              final rawProjects = improvedData['projects'] as List;
              for (int i = 0; i < rawProjects.length; i++) {
                final projMap = rawProjects[i];
                if (projMap is Map) {
                  final name = (projMap['name'] as String?)?.trim() ?? '';
                  final key = name.toLowerCase();
                  if (name.isNotEmpty && seenProjectNames.contains(key)) {
                    continue; // Skip duplicate project entries!
                  }
                  if (key.isNotEmpty) seenProjectNames.add(key);

                  final original = i < preservedProjects.length ? preservedProjects[i] : null;
                  newProjects.add(ProjectItem(
                    name: name.isNotEmpty ? name : (original?.name ?? ''),
                    role: (projMap['role'] as String?)?.trim() ?? (original?.role ?? ''),
                    startDate: (projMap['start_date'] as String?)?.trim() ?? (original?.startDate ?? ''),
                    endDate: (projMap['end_date'] as String?)?.trim() ?? (original?.endDate ?? ''),
                    isCurrent: original?.isCurrent ?? false,
                    description: (projMap['description'] as String?)?.trim() ?? (original?.description ?? ''),
                  ));
                }
              }
            }

            // Fallback deduplication from preserved projects if AI returned no projects
            if (newProjects.isEmpty) {
              for (final p in preservedProjects) {
                final key = p.name.trim().toLowerCase();
                if (key.isNotEmpty && seenProjectNames.contains(key)) continue;
                if (key.isNotEmpty) seenProjectNames.add(key);
                newProjects.add(p);
              }
            }

            cv.projects = newProjects;
          } else {
            cv.projects = [];
          }
        }

        // Restore and guarantee that core user sections are 100% intact
        cv.languages = preservedLanguages;
        cv.hobbies = preservedHobbies;
        // JIKA USER TIDAK MEMILIKI SERTIFIKASI / PROYEK, JAMIN TETAP KOSONG 100%
        if (preservedCertifications.isEmpty) {
          cv.certifications = [];
        }
        if (preservedProjects.isEmpty) {
          cv.projects = [];
        }
        cv.educations = preservedEducations;
        cv.personalInfo = preservedPersonalInfo;
        cv.showLanguages = preservedShowLanguages;
        cv.showHobbies = preservedShowHobbies;
        cv.showCertifications = preservedShowCertifications;
        cv.showProjects = preservedShowProjects;

        final newScore = (improved?['estimated_new_score'] as num?)?.toInt() ?? 96;
        final changesList = (improved?['changes_made'] as List?)?.map((c) => c.toString()).toList() ?? [];
        const newVerdict = 'Top 5% ATS Ready';
        final newBreakdown = {
          'keyword_match': 25,
          'impact_verbs': 24,
          'readability': 24,
          'completeness': cv.certifications.isEmpty ? 22 : 25,
        };

        // If user has no certifications, keep an informative guidance feedback item
        final newFeedback = <dynamic>[];
        if (cv.certifications.isEmpty) {
          newFeedback.add({
            'section': 'Sertifikasi / Pelatihan',
            'priority': 'Sedang',
            'issue': 'Seksi sertifikasi belum diisi di tab Editor.',
            'suggestion': 'Tambahkan sertifikasi riil Anda (AI tidak memalsukan sertifikat) di tab Editor untuk memvalidasi keahlian teknis secara penuh.',
            'example': 'Contoh: AWS Certified Developer / Certified Golang Engineer / Dicoding / Scrum Master',
          });
        }

        setState(() {
          _score = newScore;
          _verdict = newVerdict;
          _breakdown = newBreakdown;
          _feedback = newFeedback;
        });
        await _profileMgr.saveCurrentProfile(
          cv,
          atsScore: newScore,
          atsVerdict: newVerdict,
          atsBreakdown: newBreakdown,
          atsFeedback: newFeedback,
        );

        if (mounted) {
          final changesSummary = changesList.isNotEmpty
              ? ' (${changesList.length} perbaikan diterapkan)'
              : '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ats.autofix_success_snack'.trArgs([newScore.toString()]) + changesSummary),
              backgroundColor: AppColors.forestPine,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'ats.analysis_failed'.tr),
            backgroundColor: AppColors.crimsonBordeaux,
            duration: const Duration(seconds: 4),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleShareScore() {
    if (_score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ats.share_untested_warning'.tr),
          backgroundColor: AppColors.mutedSteelSlate,
        ),
      );
      return;
    }
    final cv = _profileMgr.currentCv;
    showDialog(
      context: context,
      builder: (_) => AtsShareCard(
        candidateName: cv.personalInfo.fullName,
        targetRole: cv.personalInfo.professionalTitle,
        score: _score!,
        verdict: _verdict ?? (_score! >= 85 ? 'ats.verdict_top_tier'.tr : 'ats.verdict_needs_opt'.tr),
        breakdown: _breakdown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oysterCanvas,
      appBar: FrostedAppBar(
        title: 'ats.checker_title'.tr,
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: _handleShareScore,
            icon: Icon(
              Icons.share_rounded,
              color: _score == null
                  ? AppColors.textSecondary.withValues(alpha: 0.4)
                  : AppColors.midnightNavy,
              size: 20,
            ),
            tooltip: _score == null
                ? 'ats.share_untested_warning'.tr
                : 'ats.share_tooltip'.tr,
          ),
        ],
      ),
      body: SingleChildScrollView(
        // UI UX Pro Max: bottom padding 24px above bottom bar & banner ad
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
                _loadCurrentProfileAts();
              },
              onRenameProfile: (newTitle, newTargetJob) {
                _profileMgr.updateProfileMeta(
                  _profileMgr.currentIndex,
                  title: newTitle.isNotEmpty ? newTitle : null,
                  targetJob: newTargetJob.isNotEmpty ? newTargetJob : null,
                );
              },
            ),
            const SizedBox(height: 14),

            // Upload & Analisa Dokumen CV (PDF / DOCX) Card
            _buildUploadDocumentCard(),
            const SizedBox(height: 14),

            // Active Template Context Info Card
            _buildActiveTemplateCard(_profileMgr.currentCv),
            const SizedBox(height: 14),

            // Incomplete Profile Warning Card (if CV is not yet ready for AI/ATS)
            if (!_profileMgr.currentCv.isEligibleForAi)
              _buildIncompleteProfileCard(),

            // Daily AI Quota Banner (Auto-Fix AI)
            ValueListenableBuilder<int>(
              valueListenable: QuotaService.instance.remainingQuotaNotifier,
              builder: (context, remainingQuota, _) {
                return DailyQuotaBanner(
                  remainingQuota: remainingQuota,
                  customTitle: remainingQuota > 0
                      ? 'Jatah Auto-Fix AI: $remainingQuota/5 Hari Ini'
                      : 'Jatah Auto-Fix AI Habis (0/5)',
                  customSubtitle: remainingQuota > 0
                      ? 'Untuk perbaikan CV dengan AI. Bisa di-bypass dengan koin.'
                      : 'Jatah harian habis. Gunakan 1 koin untuk perbaikan CV AI.',
                );
              },
            ),
            const SizedBox(height: 14),

            // Hero Score Gauge Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderHairline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AtsScoreGauge(score: _score, verdict: _verdict),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Check / Re-check button
                      Expanded(
                        child: _score == null
                            ? ElevatedButton.icon(
                                onPressed: _isLoading ? null : _handleRunCheck,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.speed_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                label: Text(
                                  'ats.run_check'.tr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.midnightNavy,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 48),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: _isLoading ? null : _handleRunCheck,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.midnightNavy,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.refresh_rounded,
                                        size: 18,
                                        color: AppColors.midnightNavy,
                                      ),
                                label: Text(
                                  'ats.recheck'.tr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.midnightNavy,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  side: const BorderSide(color: AppColors.borderHairline),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      // 1-Click Auto-Fix button
                      Expanded(
                        child: ValueListenableBuilder<int>(
                          valueListenable: QuotaService.instance.remainingQuotaNotifier,
                          builder: (context, remainingQuota, _) {
                            final hasQuota = remainingQuota > 0;
                            return ElevatedButton.icon(
                              onPressed: _isLoading ? null : _handleAutoFix,
                              icon: Icon(
                                hasQuota ? Icons.auto_fix_high_rounded : Icons.toll_rounded,
                                size: 18,
                                color: hasQuota ? Colors.white : const Color(0xFFFEF3C7),
                              ),
                              label: Text(
                                hasQuota ? 'ats.auto_fix_btn'.tr : 'Auto-Fix (1 Koin)',
                                style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasQuota ? AppColors.forestPine : const Color(0xFFD97706),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 48),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_parsedCvData != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _showSlotSelectionModal,
                        icon: const Icon(Icons.auto_fix_high_rounded, size: 20, color: Colors.white),
                        label: Text(
                          '✦ Sesuaikan CV & Simpan ke Slot (CV 1/2/3)',
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.midnightNavy,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Breakdown Section
            AtsBreakdownSection(
              breakdown: _breakdown,
              keywordAnalysis: _keywordAnalysis,
            ),
            const SizedBox(height: 16),

            // Recommendations / Actionable Feedback Section
            AtsFeedbackSection(feedbackList: _feedback, isAnalyzed: _score != null),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTemplateCard(CvDocument cv) {
    final template = TemplateRegistry.getTemplate(cv.templateId);
    final isAts = template.isAtsFriendly;
    final badgeColor = isAts ? AppColors.forestPine : AppColors.antiqueBronze;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAts ? Icons.verified_rounded : Icons.palette_outlined,
                size: 18,
                color: badgeColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Template: ${template.nameKey.tr}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isAts ? 'ats.badge_ats_ready'.tr : 'ats.badge_creative_non_ats'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          if (!isAts) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.antiqueBronze.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ats.creative_template_hint'.tr,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        cv.templateId = 'asian_ats';
                        await _profileMgr.saveCurrentProfile(cv);
                        setState(() {});
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('ats.switched_to_asian_ats_snack'.tr),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppColors.forestPine,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: AppColors.midnightNavy),
                      label: Text(
                        'ats.switch_to_asian_ats_btn'.tr,
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.midnightNavy),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.midnightNavy, width: 0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIncompleteProfileCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.subtleSlateTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.antiqueBronze.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.antiqueBronze.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.antiqueBronze,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ats.incomplete_profile_title'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'ats.incomplete_banner_hint'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadDocumentCard() {
    final hasUploaded = _uploadedFileName != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasUploaded ? AppColors.forestPine.withValues(alpha: 0.5) : AppColors.borderHairline,
          width: hasUploaded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: (hasUploaded ? AppColors.forestPine : AppColors.midnightNavy).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasUploaded ? Icons.task_alt_rounded : Icons.upload_file_rounded,
                  color: hasUploaded ? AppColors.forestPine : AppColors.midnightNavy,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasUploaded ? 'Dokumen CV Terunggah' : 'Unggah CV (PDF / DOCX)',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasUploaded
                          ? _uploadedFileName!
                          : 'Ekstraksi 100% lokal di HP, hemat kuota & privasi aman.',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        color: hasUploaded ? AppColors.forestPine : AppColors.textSecondary,
                        fontWeight: hasUploaded ? FontWeight.w600 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleUploadDocument,
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                  label: Text(
                    hasUploaded ? 'Ganti Berkas CV' : 'Pilih File (PDF/DOCX)',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.midnightNavy,
                    minimumSize: const Size(0, 44),
                    side: const BorderSide(color: AppColors.borderHairline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              if (_parsedCvData != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _showSlotSelectionModal,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      'Terapkan ke Slot',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestPine,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 44),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

