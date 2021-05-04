class CollectionUtil {
  static removeBracketsFromSet(Set<Object> givenSet) {
    final input = givenSet.toString();
    return input.substring(1, input.length - 1);
  }
}
