import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String subTitle;
  final String link;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.subTitle,
    required this.link,
  });
}

const appMenuItems = <MenuItem>[
  MenuItem(
    title: 'Progress Indicators',
    subTitle: 'Indicadores de progreso circular y lineal',
    link: '/progress',
    icon: Icons.refresh_rounded,
  ),
  MenuItem(
    title: 'Tema',
    subTitle: 'Cambiar colores y modo oscuro',
    link: '/theme-changer',
    icon: Icons.palette_outlined,
  ),
  MenuItem(
    title: 'Botones',
    subTitle: 'Varios botones en Flutter',
    link: '/buttons',
    icon: Icons.smart_button_outlined,
  ),

  MenuItem(
    title: 'Tarjetas',
    subTitle: 'Un contenedor estilizado',
    link: '/cards',
    icon: Icons.credit_card,
  ),
];
