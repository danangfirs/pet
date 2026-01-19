import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../data/dummy_data.dart';

class PetService extends ChangeNotifier {
  List<Pet> _pets = List.from(dummyPets);
  int _selectedPetIndex = 0;

  List<Pet> get pets => _pets;
  Pet? get selectedPet => _pets.isNotEmpty ? _pets[_selectedPetIndex] : null;
  int get selectedPetIndex => _selectedPetIndex;

  void addPet(Pet pet) {
    _pets.add(pet);
    notifyListeners();
  }

  void selectPet(int index) {
    if (index >= 0 && index < _pets.length) {
      _selectedPetIndex = index;
      notifyListeners();
    }
  }

  void removePet(String id) {
    _pets.removeWhere((pet) => pet.id == id);
    if (_selectedPetIndex >= _pets.length) {
      _selectedPetIndex = _pets.length - 1;
    }
    notifyListeners();
  }
}

