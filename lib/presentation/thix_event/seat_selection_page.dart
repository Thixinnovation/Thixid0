// lib/presentation/thix_event/seat_selection_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';  // ← AJOUTER CET IMPORT

import '../../providers/event_provider.dart';
import '../../models/event_model.dart';
import '../../models/event_seat.dart';
import '../../services/event_seat_service.dart';
import 'event_reservation_page.dart';

class SeatSelectionPage extends StatefulWidget {
  final String eventId;
  final Event? event;

  const SeatSelectionPage({
    super.key,
    required this.eventId,
    this.event,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  late EventSeatService _seatService;
  List<EventSeat> _seats = [];
  List<EventSeat> _selectedSeats = [];
  bool _isLoading = true;
  int _availableSeats = 0;

  @override
  void initState() {
    super.initState();
    _seatService = EventSeatService(Supabase.instance.client);  // ✅ Correction
    _loadSeatMap();
  }
  
  Future<void> _loadSeatMap() async {
    final seats = await _seatService.getSeatMap(widget.eventId);
    final available = await _seatService.getAvailableSeatsCount(widget.eventId);
    setState(() {
      _seats = seats;
      _availableSeats = available;
      _isLoading = false;
    });
  }

  void _onSeatSelected(EventSeat seat) {
    setState(() {
      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
      } else {
        _selectedSeats.add(seat);
      }
    });
  }

  double get _totalPrice {
    return _selectedSeats.fold(0, (sum, seat) => sum + seat.categoryPrice);
  }

  Future<void> _confirmSelection() async {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner des places')),
      );
      return;
    }

    final seatIds = _selectedSeats.map((s) => s.id).toList();
    final reserved = await _seatService.reserveSeats(widget.eventId, seatIds);
    
    if (reserved && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventReservationPage(
            eventId: widget.eventId,
            selectedSeats: _selectedSeats,
            totalPrice: _totalPrice,
          ),
        ),
      ).then((_) => _loadSeatMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Choisissez vos places', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Compteur places disponibles
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Places disponibles', style: TextStyle(fontSize: 13)),
                      Text(
                        '$_availableSeats',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                      ),
                    ],
                  ),
                ),
                // Légende
                _buildLegend(),
                // Plan de salle
                Expanded(
                  child: _buildSeatMap(),
                ),
                // Résumé et validation
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedSeats.length} place(s) sélectionnée(s)',
                            style: const TextStyle(fontSize: 13),
                          ),
                          Text(
                            '${_totalPrice.toStringAsFixed(0)} FC',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedSeats.isEmpty ? null : _confirmSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: const Color(0xFF0B1B3D),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('VALIDER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _legendItem(Colors.green, 'Disponible'),
          _legendItem(const Color(0xFFD4AF37), 'Sélectionnée'),
          _legendItem(Colors.orange, 'Réservée (15min)'),
          _legendItem(Colors.red, 'Vendue'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildSeatMap() {
    // Grouper les places par rangée
    final Map<String, List<EventSeat>> rows = {};
    for (var seat in _seats) {
      rows.putIfAbsent(seat.row, () => []).add(seat);
    }

    final sortedRows = rows.keys.toList()..sort();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Scène
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('SCÈNE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
          ),
          // Plan des places
          for (var row in sortedRows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      row,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: rows[row]!.map((seat) {
                        final isSelected = _selectedSeats.contains(seat);
                        final isAvailable = seat.isAvailable;
                        final isReserved = seat.isReserved;
                        final isSold = seat.isSold;
                        
                        Color seatColor;
                        if (isSelected) seatColor = const Color(0xFFD4AF37);
                        else if (isSold) seatColor = Colors.red;
                        else if (isReserved) seatColor = Colors.orange;
                        else seatColor = Colors.green;
                        
                        return GestureDetector(
                          onTap: isAvailable || isSelected ? () => _onSeatSelected(seat) : null,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: seatColor.withOpacity(0.15),
                              border: Border.all(color: seatColor, width: 1.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                seat.number.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: seatColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          // Couloir central
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 20,
            color: Colors.grey[200],
            child: const Center(
              child: Text('COULOIR', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}
