import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:essivi_mobile/theme/app_colors.dart';
import 'package:essivi_mobile/routes/app_routes.dart';
import 'package:essivi_mobile/data/repositories/sales_repository.dart';
import 'package:essivi_mobile/data/models/sales_models.dart';
import 'package:essivi_mobile/services/phone_service.dart';
import 'package:essivi_mobile/data/repositories/user_repository.dart';
import 'package:essivi_mobile/data/models/user_models.dart';
import 'package:essivi_mobile/presentation/widgets/rate_agent_modal.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> shipmentData;

  const ShipmentDetailsScreen({super.key, required this.shipmentData});

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  final _salesRepo = SalesRepository();
  final _userRepo = UserRepository();
  Commande? _commande;
  AgentProfile? _agentProfile;
  CustomUser? _clientUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommandeDetails();
  }

  Future<void> _loadCommandeDetails() async {
    try {
      // Extract ID from shipment data
      final idString = widget.shipmentData['id'] as String;
      final id = int.parse(idString.replaceAll('#', ''));
      
      _commande = await _salesRepo.getCommande(id);
      
      final isAgent = widget.shipmentData['isAgent'] == true;
      
      if (isAgent) {
        // Load client details for the agent
         try {
           _clientUser = await _userRepo.getUserById(_commande!.clientId);
         } catch (e) {
           debugPrint('Erreur chargement profil client: $e');
         }
      } else {
        // Load agent details for the client
        if (_commande?.agentId != null) {
          try {
            _agentProfile = await _userRepo.getAgentById(_commande!.agentId!);
          } catch (agentError) {
             debugPrint('Erreur chargement profil agent: $agentError');
          }
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmReception() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la réception'),
        content: const Text('Avez-vous bien reçu votre commande d\'eau ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Oui, Reçu'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _salesRepo.confirmCommande(_commande!.id);
        await _loadCommandeDetails();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Réception confirmée ! Merci de votre confiance.'),
              backgroundColor: Colors.green,
            ),
          );

          // Show rating modal if there is an agent assigned
          if (_commande!.agentId != null) {
            String agentName = _agentProfile?.user?.fullName ?? _agentProfile?.user?.username ?? 'Livreur';
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => RateAgentModal(
                commandeId: _commande!.id,
                agentId: _commande!.agentId!,
                agentName: agentName,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAgent = widget.shipmentData['isAgent'] == true;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isAgent ? 'Détails Livraison' : 'Shipment Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _commande == null
              ? const Center(child: Text('Commande non trouvée'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${_commande!.id}',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _commande!.statutLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Details Section
                      _buildInfoSection(
                        'Order Information',
                        [
                          if (isAgent && _clientUser != null)
                             _buildInfoRow('Client', '${_clientUser!.firstName} ${_clientUser!.lastName}'.trim().isNotEmpty ? '${_clientUser!.firstName} ${_clientUser!.lastName}' : _clientUser!.username),
                          _buildInfoRow('Amount', '${_commande!.montant.toStringAsFixed(0)} FCFA'),
                          _buildInfoRow('Status', _commande!.statutLabel),
                          _buildInfoRow('Created', DateTime.parse(_commande!.createdAt).toString().substring(0, 16)),
                          _buildInfoRow('Delivery Date', _commande!.dateSouhaitee.substring(0, 10)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Actions
                      if (!_commande!.isDelivered && !_commande!.isCancelled)
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context, 
                                    AppRoutes.trackDelivery,
                                    arguments: {
                                      'deliveryId': _commande!.id,
                                      'agentId': _commande!.agentId ?? 0,
                                      'agentName': isAgent ? 'Client' : (_agentProfile?.user?.fullName ?? 'Livreur'),
                                      'agentPhone': isAgent ? (_clientUser?.phoneNumber ?? '') : (_agentProfile?.user?.phoneNumber ?? ''),
                                      'clientLatitude': _commande!.deliveryLatitude,
                                      'clientLongitude': _commande!.deliveryLongitude,
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(FluentIcons.location_24_filled, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Suivre la Livraison',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (!isAgent && _commande!.isValidated) // Client confirms
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _isLoading ? null : _confirmReception,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                    side: const BorderSide(color: Colors.green, width: 2),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(FluentIcons.checkmark_circle_24_regular),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Confirmer la Réception',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = widget.shipmentData['status'] as String;
    final isInProgress = status == 'En cours' || status == 'In Progress' || status == 'validated' || status == 'pending';
    final isAgent = widget.shipmentData['isAgent'] == true;
    
    // Récupérer le nom et le numéro cible (Client ou Agent)
    String targetName;
    String targetPhone;
    
    if (isAgent) {
      targetName = _clientUser?.fullName ?? _clientUser?.username ?? 'Client';
      targetPhone = _clientUser?.phoneNumber ?? '';
    } else {
      targetName = _agentProfile?.user?.fullName ?? 'Agent Essivi';
      targetPhone = _agentProfile?.user?.phoneNumber ?? '+22890123456';
    }

    if (!isInProgress) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Bouton Suivre (Only meaningful if there is location tracking, for now generic)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.trackDelivery,
                    arguments: {
                      'deliveryId': _commande?.id ?? 0,
                      'agentId': _commande?.agent ?? 0,
                      'agentName': targetName,
                      'agentPhone': targetPhone,
                      'clientLatitude': _commande?.deliveryLatitude,
                      'clientLongitude': _commande?.deliveryLongitude,
                    },
                  );
                },
                icon: const Icon(FluentIcons.location_24_regular),
                label: Text(
                  'Suivre',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Bouton Appeler
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (targetPhone.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Numéro de téléphone non disponible')),
                     );
                     return;
                  }
                  
                  try {
                    await PhoneService.makeCall(targetPhone);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Impossible d\'appeler : $targetPhone',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(FluentIcons.call_24_filled),
                label: Text(
                  'Appeler ${isAgent ? "Client" : "Livreur"}',
                  style: GoogleFonts.poppins(
                    fontSize: 12, // Reduced size to fit
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
