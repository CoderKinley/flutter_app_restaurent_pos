import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/tax_settings_bloc/bloc/tax_settings_bloc.dart';

class TaxSettingsPage extends StatefulWidget {
  const TaxSettingsPage({super.key});

  @override
  State<TaxSettingsPage> createState() => _TaxSettingsPageState();
}

class _TaxSettingsPageState extends State<TaxSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _bstController = TextEditingController();
  final _serviceChargeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<TaxSettingsBloc>().add(LoadTaxSettings());
  }

  @override
  void dispose() {
    _bstController.dispose();
    _serviceChargeController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _saveTaxSettings() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    context.read<TaxSettingsBloc>().add(
          UpdateTaxSettings(
            bst: double.parse(_bstController.text),
            serviceCharge: double.parse(_serviceChargeController.text),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaxSettingsBloc, TaxSettingsState>(
      listener: (context, state) {
        if (state is TaxSettingsLoading) {
          setState(() {
            _isSubmitting = true;
          });
        } else {
          setState(() {
            _isSubmitting = false;
          });

          if (state is TaxSettingsError) {
            _showSnackBar(state.message, isError: true);
          } else if (state is TaxSettingsLoaded) {
            if (_bstController.text.isNotEmpty) {
              _showSnackBar('Tax settings saved successfully!');
            }
            _bstController.text = state.bst.toString();
            _serviceChargeController.text = state.serviceCharge.toString();
          }
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tax Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 3, 27, 48),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _bstController,
                      decoration: InputDecoration(
                        labelText: 'BST (%)',
                        hintText: 'Enter BST percentage',
                        prefixIcon: const Icon(Icons.percent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter BST percentage';
                        }
                        final number = double.tryParse(value);
                        if (number == null || number < 0) {
                          return 'Please enter a valid percentage';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _serviceChargeController,
                      decoration: InputDecoration(
                        labelText: 'Service Charge (%)',
                        hintText: 'Enter service charge percentage',
                        prefixIcon: const Icon(Icons.receipt_long),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter service charge percentage';
                        }
                        final number = double.tryParse(value);
                        if (number == null || number < 0) {
                          return 'Please enter a valid percentage';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _saveTaxSettings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Tax Settings',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
