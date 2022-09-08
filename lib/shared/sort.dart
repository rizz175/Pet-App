List sorted(Iterable input, [compare, key]) {
  comparator(compare, key) {
    if (compare == null && key == null)
      return (a, b) => a.compareTo(b);
    if (compare == null)
      return (a, b) => key(a).compareTo(key(b));
    if (key == null)
      return compare;
    return (a, b) => compare(key(a), key(b));
  }
  List copy = new List.from(input);
  copy.sort(comparator(compare, key));
  return copy;
}