import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/branch_bloc/bloc/branch_bloc.dart';

class BranchSettingsPage extends StatefulWidget {
  const BranchSettingsPage({super.key});

  @override
  State<BranchSettingsPage> createState() => _BranchSettingsPageState();
}

class _BranchSettingsPageState extends State<BranchSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _branchNameController = TextEditingController();
  final _branchCodeController = TextEditingController();
  bool _isSubmitting = false;

  // Apple Fruit Colors 🍎
  final Color appleRed = const Color(0xFFE74C3C); // Ripe red apple
  final Color appleGreen = const Color(0xFF2ECC71); // Fresh green apple
  final Color appleLeaf = const Color(0xFF27AE60); // Leaf green
  final Color appleStem = const Color(0xFF8B4513); // Wooden stem brown
  final Color appleCream = const Color(0xFFFDF2E9); // Apple flesh cream

  @override
  void initState() {
    super.initState();
    context.read<BranchBloc>().add(const LoadBranch());
  }

  @override
  void dispose() {
    _branchNameController.dispose();
    _branchCodeController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? appleRed : appleGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appleCream, // Soft apple flesh background
      appBar: AppBar(
        title: const Text('Branch Settings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: appleLeaf, // Fresh leaf green AppBar
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: BlocListener<BranchBloc, BranchState>(
          listener: (context, state) {
            if (state is BranchLoading) {
              setState(() => _isSubmitting = true);
            } else if (state is BranchError) {
              _showSnackBar(state.message, isError: true);
              setState(() => _isSubmitting = false);
            } else if (state is BranchLoaded) {
              if (_branchNameController.text.isNotEmpty) {
                _showSnackBar('Branch saved successfully!');
              }
              _branchNameController.text = state.branchName;
              _branchCodeController.text = state.branchCode;
              setState(() => _isSubmitting = false);
            }
          },
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: appleStem.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Branch Name Field
                    TextFormField(
                      controller: _branchNameController,
                      decoration: InputDecoration(
                        labelText: 'Branch Name',
                        prefixIcon: Icon(Icons.store, color: appleLeaf),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: appleStem.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: appleGreen, width: 2),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 20),

                    // Branch Code Field
                    TextFormField(
                      controller: _branchCodeController,
                      decoration: InputDecoration(
                        labelText: 'Branch Code',
                        prefixIcon: Icon(Icons.numbers, color: appleLeaf),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: appleStem.withOpacity(0.3)),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _saveBranch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appleRed, // Ripe apple red
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          shadowColor: appleRed.withOpacity(0.4),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('SAVE BRANCH',
                                style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _saveBranch() {
    if (_formKey.currentState!.validate()) {
      context.read<BranchBloc>().add(
            SaveBranch(
              branchName: _branchNameController.text.trim(),
              branchCode: _branchCodeController.text.trim(),
            ),
          );
    }
  }
}
