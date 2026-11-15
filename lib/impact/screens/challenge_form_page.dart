// Form tambah/ubah tantangan; validasinya sama dengan ChallengeForm di web
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../impact_api.dart';
import '../models.dart';
import '../widgets.dart';

class ChallengeFormPage extends StatefulWidget {
  final Challenge? challenge; // null = tambah, ada isinya = ubah

  const ChallengeFormPage({super.key, this.challenge});

  @override
  State<ChallengeFormPage> createState() => _ChallengeFormPageState();
}

class _ChallengeFormPageState extends State<ChallengeFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.challenge?.title);
  late final _target = TextEditingController(text: '${widget.challenge?.target ?? 3}');
  late String _kind = widget.challenge?.kind ?? 'donasi';
  late DateTime _start = widget.challenge?.startDate ?? DateUtils.dateOnly(DateTime.now());
  late DateTime _end = widget.challenge?.endDate ?? _start.add(const Duration(days: 7)); // default 7 hari, sama dengan web
  Map<String, dynamic> _serverErrors = {};
  bool _saving = false;

  bool get _isEdit => widget.challenge != null;

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    super.dispose();
  }

  // pesan error dari server untuk satu field, mis. {"target": ["Target minimal 1."]}
  String? _serverError(String field) {
    final errors = _serverErrors[field];
    return errors is List && errors.isNotEmpty ? errors.first.toString() : null;
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  String _isoDate(DateTime date) => date.toIso8601String().substring(0, 10); // "YYYY-MM-DD"

  Future<void> _submit() async {
    setState(() => _serverErrors = {});
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'title': _title.text.trim(),
      'kind': _kind,
      'target': int.parse(_target.text),
      'start_date': _isoDate(_start),
      'end_date': _isoDate(_end),
    };
    final api = ImpactApi(context.read<CookieRequest>());
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await api.updateChallenge(widget.challenge!.id, data);
      } else {
        await api.createChallenge(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_isEdit ? 'Perubahan tantangan disimpan.' : 'Tantangan disimpan.')));
      Navigator.pop(context, true); // true = halaman sebelumnya perlu memuat ulang
    } on ImpactApiException catch (e) {
      setState(() => _serverErrors = e.fieldErrors);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final endError = _end.isBefore(_start) ? 'Tanggal selesai tidak boleh sebelum tanggal mulai.' : _serverError('end_date');
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Ubah Tantangan' : 'Tambah Tantangan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              maxLength: 120,
              decoration: InputDecoration(
                labelText: 'Judul tantangan',
                hintText: 'mis. Jual 3 barang minggu ini',
                errorText: _serverError('title'),
              ),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Judul wajib diisi.' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _kind,
              decoration: InputDecoration(labelText: 'Jenis aksi', errorText: _serverError('kind')),
              items: [
                for (final entry in challengeKinds.entries) DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (value) => setState(() => _kind = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _target,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Target', errorText: _serverError('target')),
              validator: (value) {
                final number = int.tryParse(value ?? '');
                if (number == null) return 'Isi dengan angka.';
                if (number < 1) return 'Target minimal 1.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _DateField(label: 'Tanggal mulai', date: _start, onTap: () => _pickDate(true))),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(label: 'Tanggal selesai', date: _end, error: endError, onTap: () => _pickDate(false)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving || _end.isBefore(_start) ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: ImpactColors.ink,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final String? error;
  final VoidCallback onTap;

  const _DateField({required this.label, required this.date, required this.onTap, this.error});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, errorText: error, errorMaxLines: 3,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18)),
        child: Text(formatDate(date)),
      ),
    );
  }
}
