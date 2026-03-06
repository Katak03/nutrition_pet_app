class PetAssetResolver {
  static String resolveAsset({required int health, required int hunger, required int happiness}) {
    if (health < 30) return 'sick_pet';
    if (hunger < 30) return 'hungry_pet';
    if (happiness < 30) return 'sad_pet';
    return 'happy_pet';
  }
}