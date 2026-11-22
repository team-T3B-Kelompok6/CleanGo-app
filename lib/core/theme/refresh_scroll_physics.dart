import 'package:flutter/material.dart';

/// Physics untuk halaman ber-RefreshIndicator.
///
/// Guliran selalu bisa dipakai (konsten bisa dipicu pada konten pendek),
/// tetapi batas overscroll menahan konten supaya tidak ikut turun: yang
/// bergerak hanya indikator refresh di atasnya.
const ScrollPhysics refreshScrollPhysics = AlwaysScrollableScrollPhysics(
  parent: ClampingScrollPhysics(),
);
