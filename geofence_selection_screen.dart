import 'package:flutter/material.dart';
import 'package:home_smart/model/geofence.dart';

class GeofenceSelectionScreen extends StatefulWidget {
  final List<Geofence> availableGeofences;
  final List<Geofence> selectedGeofences;
  final Function(List<Geofence>) onGeofencesSelected;

  const GeofenceSelectionScreen({
    Key? key,
    required this.availableGeofences,
    required this.selectedGeofences,
    required this.onGeofencesSelected,
  }) : super(key: key);

  @override
  _GeofenceSelectionScreenState createState() =>
      _GeofenceSelectionScreenState();
}

class _GeofenceSelectionScreenState extends State<GeofenceSelectionScreen> {
  late List<Geofence> _selectedGeofences;

  @override
  void initState() {
    super.initState();
    _selectedGeofences = List.from(widget.selectedGeofences);
  }

  void _toggleGeofence(Geofence geofence) {
    setState(() {
      if (_selectedGeofences.contains(geofence)) {
        _selectedGeofences.remove(geofence);
      } else {
        _selectedGeofences.add(geofence);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Geofences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onGeofencesSelected(_selectedGeofences);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: widget.availableGeofences.length,
        itemBuilder: (context, index) {
          final geofence = widget.availableGeofences[index];
          final isSelected = _selectedGeofences.contains(geofence);
          return CheckboxListTile(
            title: Text(geofence.id), // Assuming Geofence has a name property
            value: isSelected,
            onChanged: (bool? value) {
              _toggleGeofence(geofence);
            },
          );
        },
      ),
    );
  }
}
