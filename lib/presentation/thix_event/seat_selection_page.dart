// lib/presentation/thix_event/seat_selection_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/event_provider.dart';
import '../../../services/event_seat_service.dart';
import '../../../models/event_seat.dart';
import 'widgets/seat_map_widget.dart';
import 'widgets/seat_legend.dart';

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
    _seatService = EventSeatService(Supabase.instance.client);
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
                const SeatLegend(),
                // Plan de salle
                Expanded(
                  child: SeatMapWidget(
                    seats: _seats,
                    selectedSeats: _selectedSeats,
                    onSeatTap: _onSeatSelected,
                  ),
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
}
