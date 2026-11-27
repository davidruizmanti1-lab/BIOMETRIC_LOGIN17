// Las fotos describen espacios, no unidades reservables ni capacidades.
enum PhotoCategory { all, bedroom, bathroom, kitchen, spaces, balcony, pool }

class VeleroPhoto {
  final String file, caption;
  final PhotoCategory category;
  const VeleroPhoto(this.file, this.caption, this.category);
  String get asset => 'assets/images/velero/$file.webp';
}

abstract final class VeleroGallery {
  static const resort = <VeleroPhoto>[
    VeleroPhoto('resort_balcon_atardecer', 'Balcón al atardecer', PhotoCategory.balcony),
    VeleroPhoto('resort_habitacion_atardecer', 'Habitación al atardecer', PhotoCategory.bedroom),
    VeleroPhoto('resort_habitacion_2', 'Habitación con ventanal', PhotoCategory.bedroom),
    VeleroPhoto('resort_habitacion_1', 'Habitación · detalles interiores', PhotoCategory.bedroom),
    VeleroPhoto('resort_sala_atardecer', 'Sala al atardecer', PhotoCategory.spaces),
    VeleroPhoto('resort_sala_dia', 'Sala con luz natural', PhotoCategory.spaces),
    VeleroPhoto('resort_terraza', 'Terraza y comedor', PhotoCategory.balcony),
    VeleroPhoto('resort_cocina', 'Cocina equipada en la fotografía', PhotoCategory.kitchen),
    VeleroPhoto('resort_piscinas', 'Vista de las piscinas', PhotoCategory.pool),
    VeleroPhoto('resort_vista_mar', 'Panorámica del mar', PhotoCategory.balcony),
  ];
  static const website = <VeleroPhoto>[
    VeleroPhoto('galeria-habitacion-clara', 'Habitación · Tacaloa Beach', PhotoCategory.bedroom),
    VeleroPhoto('galeria-sala', 'Sala · Tacaloa Beach', PhotoCategory.spaces),
    VeleroPhoto('galeria-cocina', 'Cocina · Tacaloa Beach', PhotoCategory.kitchen),
    VeleroPhoto('galeria-balcon', 'Balcón · Tacaloa Beach', PhotoCategory.spaces),
  ];
  static const owner = <VeleroPhoto>[
    VeleroPhoto('habitacion_01', 'Habitación · cama amplia', PhotoCategory.bedroom),
    VeleroPhoto('habitacion_02', 'Habitación · vista lateral', PhotoCategory.bedroom),
    VeleroPhoto('bano_01', 'Baño · ducha de vidrio', PhotoCategory.bathroom),
    VeleroPhoto('dos_camas_01', 'Habitación · dos camas', PhotoCategory.bedroom),
    VeleroPhoto('habitacion_03', 'Habitación · entrada', PhotoCategory.bedroom),
    VeleroPhoto('bano_02', 'Baño · lavamanos y ducha', PhotoCategory.bathroom),
    VeleroPhoto('dos_camas_02', 'Habitación · decoración aguamarina', PhotoCategory.bedroom),
    VeleroPhoto('cocina_01', 'Cocina · vista general', PhotoCategory.kitchen),
    VeleroPhoto('cocina_02', 'Cocina · utensilios', PhotoCategory.kitchen),
    VeleroPhoto('dos_camas_03', 'Habitación · vista desde la ventana', PhotoCategory.bedroom),
    VeleroPhoto('dos_camas_04', 'Habitación · dos camas y mesa', PhotoCategory.bedroom),
    VeleroPhoto('bano_03', 'Baño · cabina de ducha', PhotoCategory.bathroom),
    VeleroPhoto('dos_camas_05', 'Habitación · cama y televisor', PhotoCategory.bedroom),
    VeleroPhoto('dos_camas_06', 'Habitación · detalle de camas', PhotoCategory.bedroom),
    VeleroPhoto('dos_camas_07', 'Habitación · mesa auxiliar', PhotoCategory.bedroom),
    VeleroPhoto('cocina_03', 'Cocina · estufa y nevera', PhotoCategory.kitchen),
  ];
  static List<PhotoCategory> categories(Set<String> assets) {
    final installed = available(assets, PhotoCategory.all)
        .map((photo) => photo.category).toSet();
    return PhotoCategory.values.where((category) =>
        category == PhotoCategory.all || installed.contains(category))
        .toList(growable: false);
  }

  static List<VeleroPhoto> available(Set<String> assets, PhotoCategory category) =>
    [...resort, ...website, ...owner].where((p) => assets.contains(p.asset) &&
      (category == PhotoCategory.all || p.category == category)).toList(growable: false);
}
