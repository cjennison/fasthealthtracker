const List<String> Quantities = ['some', 'half', 'full', 'extra'];

String getQuantitiesDisplayName(String quantity) {
  switch (quantity) {
    case 'some':
      return 'Some';
    case 'half':
      return 'Half';
    case 'full':
      return 'Full';
    case 'extra':
      return 'Extra';
    default:
      throw ArgumentError('Invalid quantity: $quantity');
  }
}
