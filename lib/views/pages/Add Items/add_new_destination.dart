import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_system_legphel/bloc/destination/bloc/destination_bloc.dart';
import 'package:pos_system_legphel/models/destination_model.dart';

class AddDestinationPage extends StatefulWidget {
  final Destination? destination;

  const AddDestinationPage({
    super.key,
    this.destination,
  });

  @override
  _AddDestinationPageState createState() => _AddDestinationPageState();
}

class _AddDestinationPageState extends State<AddDestinationPage> {
  final _formKey = GlobalKey<FormState>();
  final _destinationNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.destination != null) {
      _destinationNameController.text = widget.destination!.name;
    }
  }

  @override
  void dispose() {
    _destinationNameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newDestination = Destination(
        name: _destinationNameController.text,
      );

      context.read<DestinationBloc>()
        ..add(AddDestination(
          name: newDestination.name,
        ))
        ..add(LoadDestinations());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination Added Successfully!')),
      );

      Navigator.pop(context);
    }
  }

  void _editForm() {
    if (_formKey.currentState!.validate()) {
      final updatedDestination = Destination(
        id: widget.destination!.id,
        name: _destinationNameController.text,
      );

      context.read<DestinationBloc>()
        ..add(UpdateDestination(
          destination: updatedDestination,
        ))
        ..add(LoadDestinations());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination Updated Successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destination == null
            ? 'Add Destination'
            : 'Edit Destination'),
      ),
      body: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _destinationNameController,
                  decoration: const InputDecoration(
                    labelText: 'Destination Name',
                    hintText: 'e.g., Bar, Kitchen, Main Kitchen',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a destination name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        widget.destination == null ? _submitForm : _editForm,
                    child: Text(
                      widget.destination == null
                          ? 'Add Destination'
                          : 'Update Destination',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
