import 'package:flutter/material.dart';

class Producto {
  final String id;
  final String tipo; // "armazon", "mica", "lente_contacto", "accesorio"
  final String codigo;
  final String nombre;
  final String descripcion;
  final String marca;
  final String modelo;
  final List<String> imagenes;
  final double precioCompra;
  final double precioVenta;
  final int stock;
  final int stockMinimo;
  final bool activo;
  final DateTime fechaAlta;
  
  // Campos específicos para armazones
  final String? materialArmazon;
  final String? colorArmazon;
  final String? formaArmazon;
  final Map<String, dynamic>? medidasArmazon;
  final String? generoArmazon;
  
  // Campos específicos para micas (ACTUALIZADO según Excel)
  final String? presentacionMica;    // Visión Sencilla, Progresivas, Bifocales, ZEISS
  final String? materialMica;        // HI Index, Policarbonato, CR, MR8, ALTA FORCE
  final List<String>? tratamientos;   // AR, Blue Block, Polarizado, Fotocromático, Espejeado
  final String? colorMica;           // Tinte, Gris, Café, Azul, Rosa, Rojo, Morado, etc.
  final String? serieMica;           // 1RA Serie, 2DA Serie, 3RA Serie
  final String? rangoGraduacion;     // Rango específico de graduación
  final String? fabricanteMica;      // ZEISS, etc.
  
  // Campos específicos para lentes de contacto (ACTUALIZADO según Excel)
  final String? tipoLC;              // Esférico, Tórico, Hidrofílico, RGP
  final String? marcaLC;             // Cooper Visión, Alcón, J&J, LUMILENT
  final String? disenoLC;            // Biofinity, Air Optix, Acuvue, etc.
  final String? materialLC;          // Hidrogel, Silicona Hidrogel, RGP
  final String? reemplazoLC;         // Diario, Quincenal, Mensual, Anual
  final String? parametrosLC;        // Curva base, diámetro, etc.
  final String? colorLC;

  Producto({
    required this.id,
    required this.tipo,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.marca,
    required this.modelo,
    required this.imagenes,
    required this.precioCompra,
    required this.precioVenta,
    required this.stock,
    required this.stockMinimo,
    required this.activo,
    required this.fechaAlta,
    this.materialArmazon,
    this.colorArmazon,
    this.formaArmazon,
    this.medidasArmazon,
    this.generoArmazon,
    // Micas
    this.presentacionMica,
    this.materialMica,
    this.tratamientos,
    this.colorMica,
    this.serieMica,
    this.rangoGraduacion,
    this.fabricanteMica,
    // Lentes de contacto
    this.tipoLC,
    this.marcaLC,
    this.disenoLC,
    this.materialLC,
    this.reemplazoLC,
    this.parametrosLC,
    this.colorLC,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['_id'] ?? json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      imagenes: List<String>.from(json['imagenes'] ?? []),
      precioCompra: (json['precios']?['costo'] ?? 0).toDouble(),
      precioVenta: (json['precios']?['precio_venta'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      stockMinimo: json['stock_minimo'] ?? 5,
      activo: json['activo'] ?? true,
      fechaAlta: json['fecha_alta'] != null 
          ? DateTime.parse(json['fecha_alta']) 
          : DateTime.now(),
      
      // Campos de armazón
      materialArmazon: json['armazon']?['material'],
      colorArmazon: json['armazon']?['color'],
      formaArmazon: json['armazon']?['forma'],
      medidasArmazon: json['armazon']?['medidas'],
      generoArmazon: json['armazon']?['genero'],
      
      // Campos de mica (actualizado)
      presentacionMica: json['mica']?['presentacion'],
      materialMica: json['mica']?['material'],
      tratamientos: List<String>.from(json['mica']?['tratamientos'] ?? []),
      colorMica: json['mica']?['color'],
      serieMica: json['mica']?['serie'],
      rangoGraduacion: json['mica']?['rango_graduacion'],
      fabricanteMica: json['mica']?['fabricante'],
      
      // Campos de lentes de contacto (actualizado)
      tipoLC: json['lente_contacto']?['tipo'],
      marcaLC: json['lente_contacto']?['marca_lc'],
      disenoLC: json['lente_contacto']?['diseno'],
      materialLC: json['lente_contacto']?['material'],
      reemplazoLC: json['lente_contacto']?['reemplazo'],
      parametrosLC: json['lente_contacto']?['parametros'],
      colorLC: json['lente_contacto']?['color'],
    );
  }

  Map<String, dynamic> toJson() {
    final baseData = {
      'tipo': tipo,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'marca': marca,
      'modelo': modelo,
      'imagenes': imagenes,
      'precios': {
        'costo': precioCompra,
        'precio_venta': precioVenta,
      },
      'stock': stock,
      'stock_minimo': stockMinimo,
      'activo': activo,
    };

    // Agregar campos específicos según el tipo
    if (tipo == 'armazon') {
      baseData['armazon'] = {
        'material': materialArmazon,
        'color': colorArmazon,
        'forma': formaArmazon,
        'medidas': medidasArmazon,
        'genero': generoArmazon,
      };
    } else if (tipo == 'mica') {
      baseData['mica'] = {
        'presentacion': presentacionMica,
        'material': materialMica,
        'tratamientos': tratamientos,
        'color': colorMica,
        'serie': serieMica,
        'rango_graduacion': rangoGraduacion,
        'fabricante': fabricanteMica,
      };
    } else if (tipo == 'lente_contacto') {
      baseData['lente_contacto'] = {
        'tipo': tipoLC,
        'marca_lc': marcaLC,
        'diseno': disenoLC,
        'material': materialLC,
        'reemplazo': reemplazoLC,
        'parametros': parametrosLC,
        'color': colorLC,
      };
    }

    return baseData;
  }

  // Helper para obtener el nombre del tipo en español
  String get tipoEnEspanol {
    switch (tipo) {
      case 'armazon':
        return 'Armazón';
      case 'mica':
        return 'Mica';
      case 'lente_contacto':
        return 'Lente de Contacto';
      case 'accesorio':
        return 'Accesorio';
      default:
        return tipo;
    }
  }

  // Helper para obtener el color de fondo según el tipo
  Color get colorTipo {
    switch (tipo) {
      case 'armazon':
        return Colors.blue;
      case 'mica':
        return Colors.green;
      case 'lente_contacto':
        return Colors.purple;
      case 'accesorio':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}