import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/frosted_app_bar.dart';
import '../../ats_checker/widgets/ats_score_gauge.dart';
import '../../pdf_engine/pdf_generator.dart';
import '../models/cv_model.dart';

class CvEditorScreen extends StatefulWidget {
  const CvEditorScreen({super.key});

  @override
  State<CvEditorScreen> createState() => _CvEditorScreenState();
}

class _CvEditorScreenState extends State<CvEditorScreen> {
  late CvDocument _cv;
  int _currentProfileIndex = 1;
  int _remainingQuota = 5;
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cv = CvDocument(
      personalInfo: PersonalInfo(
        fullName: 'Alexander Wright',
        professionalTitle: 'Lead Mobile Architect',
        email: 'alexander.wright@executive.io',
        phone: '+62 812-9876-5432',
        location: 'Jakarta, Indonesia',
        linkedin: 'linkedin.com/in/alexander-wright',
      ),
      summary:
          'Accomplished Lead Mobile Architect with 7+ years of expertise architecting high-throughput fintech and SaaS solutions. Proven track record of scaling apps to 2M+ MAU with 99.98% crash-free sessions.',
      experiences: [
        WorkExperience(
          company: 'Zenith Global Technologies',
          position: 'Lead Mobile Engineer',
          startDate: '2022',
          endDate: 'Present',
          highlights: [
            'Architected client-side offline-first caching layer, cutting API latency by 45% for 1.2M active users.',
            'Spearheaded Flutter migration across 3 cross-functional teams, accelerating sprint delivery cycle by 35%.',
          ],
        ),
      ],
      educations: [
        Education(
          institution: 'Institute of Technology',
          degree: 'Bachelor of Science',
          fieldOfStudy: 'Computer Science',
          graduationYear: '2020',
          gpa: '3.85',
        ),
      ],
      skills: ['Flutter', 'Dart', 'Clean Architecture', 'REST APIs', 'CI/CD', 'Docker', 'SQLite'],
    );

    _syncControllersFromModel();
    _fetchQuota();
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

  Future<void> _fetchQuota() async {
    try {
      final quotaData = await ApiService.instance.getQuota();
      if (quotaData['success'] == true && mounted) {
        setState(() {
          _remainingQuota = quotaData['quota']['remaining'] ?? 5;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _cv.personalInfo.localPhotoPath = picked.path;
      });
    }
  }

  Future<void> _handleGenerateAi() async {
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('common.success'.tr)),
        );
      } else if (mounted) {
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

  Future<void> _handleAtsCheck() async {
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
        _showAtsReportModal(
          score: result['total_score'] ?? 92,
          breakdown: result['breakdown'],
          feedback: result['actionable_feedback'],
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

  void _showAtsReportModal({
    required int score,
    Map<String, dynamic>? breakdown,
    List<dynamic>? feedback,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.oysterCanvas,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderHairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'ats.checker_title'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.midnightNavy,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: AtsScoreGauge(
                    score: score,
                    breakdown: breakdown,
                    actionableFeedback: feedback,
                    onAutoFixTap: () {
                      Navigator.pop(ctx);
                      _handleAutoFix();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleAutoFix() async {
    _syncModelFromControllers();
    setState(() => _isLoading = true);

    try {
      final plainText = _cv.toPlainText();
      final response = await ApiService.instance.autoFixAts(plainText);

      if (response['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CV berhasil diperbaiki! Skor meningkat ke 96+'),
            backgroundColor: AppColors.forestPine,
          ),
        );
        _fetchQuota();
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

  Future<void> _handleExportPdf() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oysterCanvas,
      appBar: FrostedAppBar(
        title: 'form.title'.tr,
        showBackButton: false,
        actions: [
          // Profile Index Switcher
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.subtleSlateTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderHairline),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _currentProfileIndex,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.midnightNavy,
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('CV 1')),
                  DropdownMenuItem(value: 2, child: Text('CV 2')),
                  DropdownMenuItem(value: 3, child: Text('CV 3')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _currentProfileIndex = val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Quota Banner
            _buildDailyQuotaBanner(),
            const SizedBox(height: 16),

            // Template Selector Card
            _buildTemplateSelectorCard(),
            const SizedBox(height: 16),

            // Personal Information Card
            _buildPersonalInfoCard(),
            const SizedBox(height: 16),

            // Executive Summary Card (Toggle ON/OFF)
            _buildSummaryCard(),
            const SizedBox(height: 16),

            // Work Experience Card
            _buildExperienceCard(),
            const SizedBox(height: 16),

            // Skills Card (Wrap Chips)
            _buildSkillsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildDailyQuotaBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.antiqueBronze.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on_rounded, color: AppColors.antiqueBronze, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'quota.remaining_count'.trArgs(['$_remainingQuota']),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.midnightNavy,
                  ),
                ),
                Text(
                  'quota.resets_info'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSelectorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'form.template_selection'.tr,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.midnightNavy,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTemplateOption(
                  title: 'Asian ATS',
                  subtitle: 'Dengan Pas Foto',
                  isSelected: _cv.templateId == 'asian_ats',
                  onTap: () => setState(() => _cv.templateId = 'asian_ats'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTemplateOption(
                  title: 'Western Strict',
                  subtitle: '1 Kolom Teks',
                  isSelected: _cv.templateId == 'western_strict',
                  onTap: () => setState(() => _cv.templateId = 'western_strict'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.subtleSlateTint : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.midnightNavy : AppColors.borderHairline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.midnightNavy : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'form.personal_info'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.midnightNavy,
                ),
              ),
              if (_cv.templateId == 'asian_ats')
                InkWell(
                  onTap: _pickPhoto,
                  child: Row(
                    children: [
                      const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.accentSteel),
                      const SizedBox(width: 4),
                      Text(
                        _cv.personalInfo.localPhotoPath != null ? 'Ganti Foto' : 'Pas Foto',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentSteel,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField('form.full_name'.tr, _nameController),
          const SizedBox(height: 10),
          _buildTextField('form.professional_title'.tr, _titleController),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField('form.email'.tr, _emailController)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField('form.phone'.tr, _phoneController)),
            ],
          ),
          const SizedBox(height: 10),
          _buildTextField('form.location'.tr, _locationController),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'form.summary'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.midnightNavy,
                ),
              ),
              Switch.adaptive(
                value: _cv.showSummary,
                activeTrackColor: AppColors.midnightNavy,
                onChanged: (val) => setState(() => _cv.showSummary = val),
              ),
            ],
          ),
          if (_cv.showSummary) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _summaryController,
              maxLines: 4,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'form.summary_hint'.tr,
                hintStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderHairline),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExperienceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'form.experience'.tr,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.midnightNavy,
                ),
              ),
              Switch.adaptive(
                value: _cv.showExperience,
                activeTrackColor: AppColors.midnightNavy,
                onChanged: (val) => setState(() => _cv.showExperience = val),
              ),
            ],
          ),
          if (_cv.showExperience) ...[
            const SizedBox(height: 12),
            ..._cv.experiences.map(
              (exp) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.subtleSlateTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${exp.position} — ${exp.company}',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...exp.highlights.map(
                      (h) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '• $h',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'form.skills'.tr,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.midnightNavy,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillInputController,
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'form.skills_hint'.tr,
                    hintStyle: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.borderHairline),
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      setState(() {
                        _cv.skills.add(val.trim());
                        _skillInputController.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  final val = _skillInputController.text.trim();
                  if (val.isNotEmpty) {
                    setState(() {
                      _cv.skills.add(val);
                      _skillInputController.clear();
                    });
                  }
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.midnightNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Skills must use Wrap per GEMINI.md Bagian 4
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _cv.skills
                .map(
                  (skill) => Chip(
                    label: Text(
                      skill,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                    backgroundColor: AppColors.subtleSlateTint,
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      setState(() => _cv.skills.remove(skill));
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.borderHairline),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderHairline),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(top: BorderSide(color: AppColors.borderHairline)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ATS Score Checker CTA
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleAtsCheck,
                icon: const Icon(Icons.speed_rounded, size: 18),
                label: Text(
                  'Uji Skor ATS',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestPine,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // AI Polish CTA
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleGenerateAi,
                icon: const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.amber),
                label: Text(
                  'Poles AI',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.midnightNavy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Export PDF
            IconButton(
              onPressed: _isLoading ? null : _handleExportPdf,
              icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.midnightNavy),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.subtleSlateTint,
                minimumSize: const Size(50, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderHairline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
