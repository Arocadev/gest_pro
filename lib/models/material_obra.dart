class MaterialObra {
  String nombre;
  double cantidad;
  double precioUnidad;

  MaterialObra({
    required this.nombre,
    required this.cantidad,
    required this.precioUnidad,
  });

  double get total => cantidad * precioUnidad;

  double get totalConIva => total * 1.21;
}