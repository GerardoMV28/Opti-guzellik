  import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AgudezaVisualWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onChanged;
  final Map<String, dynamic>? initialValue;

  const AgudezaVisualWidget({
    Key? key,
    required this.onChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  State<AgudezaVisualWidget> createState() => _AgudezaVisualWidgetState();
}

class _AgudezaVisualWidgetState extends State<AgudezaVisualWidget> {
  final List<String> escalas = [
    '20/20', '20/25', '20/30', '20/40', '20/50', 
    '20/60', '20/70', '20/100', '20/200', '20/400'
  ];

  late Map<String, String> sinLentes;
  late Map<String, String> conLentes;
  late Map<String, String> estenopeica;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialValue != null) {
      sinLentes = Map<String, String>.from(
        widget.initialValue!['sin_lentes'] ?? 
        {'od': '20/20', 'oi': '20/20', 'ao': '20/20'}
      );
      conLentes = Map<String, String>.from(
        widget.initialValue!['con_lentes'] ?? 
        {'od': '20/20', 'oi': '20/20', 'ao': '20/20'}
      );
      estenopeica = Map<String, String>.from(
        widget.initialValue!['estenopeica'] ?? 
        {'od': '20/20', 'oi': '20/20'}
      );
    } else {
      sinLentes = {'od': '20/20', 'oi': '20/20', 'ao': '20/20'};
      conLentes = {'od': '20/20', 'oi': '20/20', 'ao': '20/20'};
      estenopeica = {'od': '20/20', 'oi': '20/20'};
    }
  }

  void _notifyChange() {
    widget.onChanged({
      'sin_lentes': sinLentes,
      'con_lentes': conLentes,
      'estenopeica': estenopeica,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título
        Row(
          children: [
            Icon(Icons.visibility, color: AppColors.azulReal, size: 20),
            SizedBox(width: 8),
            Text(
              'Agudeza Visual',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.azulReal,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // SIN LENTES
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.visibility_off, color: Colors.grey[600], size: 16),
                    SizedBox(width: 8),
                    Text(
                      'SIN LENTES (Visión natural)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildFilaAgudeza('Ojo Derecho (OD)', 'od', sinLentes),
                _buildFilaAgudeza('Ojo Izquierdo (OI)', 'oi', sinLentes),
                _buildFilaAgudeza('Ambos Ojos (AO)', 'ao', sinLentes),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),

        // CON LENTES
        Container(
          decoration: BoxDecoration(
            color: AppColors.turquesa.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.turquesa.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.visibility, color: AppColors.turquesa, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'CON LENTES (Visión corregida)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.turquesa,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildFilaAgudeza('Ojo Derecho (OD)', 'od', conLentes),
                _buildFilaAgudeza('Ojo Izquierdo (OI)', 'oi', conLentes),
                _buildFilaAgudeza('Ambos Ojos (AO)', 'ao', conLentes),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),

        // ESTENOPEICA
        Container(
          decoration: BoxDecoration(
            color: AppColors.azulCobalto.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.azulCobalto.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.circle_outlined, color: AppColors.azulCobalto, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'ESTENOPEICA (Agujero)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.azulCobalto,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildFilaAgudeza('Ojo Derecho (OD)', 'od', estenopeica),
                _buildFilaAgudeza('Ojo Izquierdo (OI)', 'oi', estenopeica),
              ],
            ),
          ),
        ),

        SizedBox(height: 16),

        // Comparación automática
        _buildComparacion(),
      ],
    );
  }

  Widget _buildFilaAgudeza(String label, String key, Map<String, String> map) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: map[key] ?? '20/20',
                  isExpanded: true,
                  items: escalas.map((escala) {
                    return DropdownMenuItem(
                      value: escala,
                      child: Text(
                        escala,
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      map[key] = valor!;
                    });
                    _notifyChange();
                  },
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.azulCobalto),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparacion() {
    // Función para convertir a número para comparar
    double getValorNumerico(String escala) {
      if (escala.contains('/')) {
        return double.parse(escala.split('/')[1]);
      }
      return 20.0; // Valor por defecto
    }

    double mejoriaOD = getValorNumerico(sinLentes['od']!) - getValorNumerico(conLentes['od']!);
    double mejoriaOI = getValorNumerico(sinLentes['oi']!) - getValorNumerico(conLentes['oi']!);
    
    String mensaje;
    Color color;
    
    if (mejoriaOD > 0 || mejoriaOI > 0) {
      mensaje = "✅ Mejoría significativa con lentes";
      color = Colors.green;
    } else if (mejoriaOD == 0 && mejoriaOI == 0) {
      mensaje = "⚠️ No hay mejora con lentes actuales";
      color = Colors.orange;
    } else {
      mensaje = "ℹ️ Visión similar con/sin lentes";
      color = Colors.blue;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            mejoriaOD > 0 ? Icons.thumb_up : Icons.info_outline,
            color: color,
            size: 18,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}