import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/ip_address_bloc/bloc/ip_address_bloc.dart';

class IpAddressPage extends StatefulWidget {
  const IpAddressPage({super.key});

  @override
  State<IpAddressPage> createState() => _IpAddressPageState();
}

class _IpAddressPageState extends State<IpAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<IpAddressBloc>().add(const LoadIpAddress());
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
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

  bool _isValidIpAddress(String ip) {
    final ipv4Regex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipv4Regex.hasMatch(ip);
  }

  bool _isValidPort(String port) {
    if (port.isEmpty) return false;
    final portNum = int.tryParse(port);
    return portNum != null && portNum > 0 && portNum <= 65535;
  }

  void _saveIpAddress() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final fullAddress =
        '${_ipController.text.trim()}:${_portController.text.trim()}';
    context.read<IpAddressBloc>().add(SaveIpAddress(fullAddress));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<IpAddressBloc, IpAddressState>(
      listener: (context, state) {
        if (state is IpAddressLoading) {
          setState(() {
            _isSubmitting = true;
          });
        } else {
          setState(() {
            _isSubmitting = false;
          });

          if (state is IpAddressError) {
            _showSnackBar(state.message, isError: true);
          } else if (state is IpAddressLoaded) {
            if (_ipController.text.isNotEmpty) {
              _showSnackBar('Server address saved successfully!');
            }
            final parts = state.ipAddress.split(':');
            if (parts.length == 2) {
              _ipController.text = parts[0];
              _portController.text = parts[1];
            }
          }
        }
      },
      child: SingleChildScrollView(
        child: Padding(
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
                        'Server Address',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 3, 27, 48),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _ipController,
                        decoration: InputDecoration(
                          labelText: 'IP Address',
                          hintText:
                              'Enter server IP address (e.g., 192.168.1.100)',
                          prefixIcon: const Icon(Icons.computer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                          _IpAddressInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an IP address';
                          }
                          if (!_isValidIpAddress(value)) {
                            return 'Please enter a valid IP address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _portController,
                        decoration: InputDecoration(
                          labelText: 'Port',
                          hintText: 'Enter port number (e.g., 8080)',
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a port number';
                          }
                          if (!_isValidPort(value)) {
                            return 'Please enter a valid port number (1-65535)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _saveIpAddress,
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
                                  'Save Server Address',
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
      ),
    );
  }
}

class _IpAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll('.', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
