import 'package:flutter_test/flutter_test.dart';
import 'package:my_games_list/models/item_model.dart';

void main() {
  group('Item Model', () {
    const testItem = Item(
      id: '1',
      name: 'Test Game',
      description: 'A test game description',
      imageUrl: 'https://example.com/image.jpg',
    );

    test('should create Item with required properties', () {
      expect(testItem.id, equals('1'));
      expect(testItem.name, equals('Test Game'));
      expect(testItem.description, equals('A test game description'));
      expect(testItem.imageUrl, equals('https://example.com/image.jpg'));
    });

    test('should create Item without imageUrl', () {
      const item = Item(
        id: '2',
        name: 'Game Without Image',
        description: 'No image game',
      );

      expect(item.id, equals('2'));
      expect(item.name, equals('Game Without Image'));
      expect(item.description, equals('No image game'));
      expect(item.imageUrl, isNull);
    });

    test('should create Item from JSON', () {
      final json = {
        'id': '1',
        'name': 'Test Game',
        'description': 'A test game description',
        'imageUrl': 'https://example.com/image.jpg',
      };

      final item = Item.fromJson(json);

      expect(item.id, equals('1'));
      expect(item.name, equals('Test Game'));
      expect(item.description, equals('A test game description'));
      expect(item.imageUrl, equals('https://example.com/image.jpg'));
    });

    test('should create Item from JSON without imageUrl', () {
      final json = {
        'id': '2',
        'name': 'Game Without Image',
        'description': 'No image game',
        'imageUrl': null,
      };

      final item = Item.fromJson(json);

      expect(item.id, equals('2'));
      expect(item.name, equals('Game Without Image'));
      expect(item.description, equals('No image game'));
      expect(item.imageUrl, isNull);
    });

    test('should convert Item to JSON', () {
      final json = testItem.toJson();

      expect(json['id'], equals('1'));
      expect(json['name'], equals('Test Game'));
      expect(json['description'], equals('A test game description'));
      expect(json['imageUrl'], equals('https://example.com/image.jpg'));
    });

    test('should create copy with updated properties', () {
      final updatedItem = testItem.copyWith(
        name: 'Updated Game',
        description: 'Updated description',
      );

      expect(updatedItem.id, equals('1')); // unchanged
      expect(updatedItem.name, equals('Updated Game')); // changed
      expect(updatedItem.description, equals('Updated description')); // changed
      expect(updatedItem.imageUrl, equals('https://example.com/image.jpg')); // unchanged
    });

    test('should implement equality correctly', () {
      const item1 = Item(
        id: '1',
        name: 'Test Game',
        description: 'A test game description',
        imageUrl: 'https://example.com/image.jpg',
      );

      const item2 = Item(
        id: '1',
        name: 'Test Game',
        description: 'A test game description',
        imageUrl: 'https://example.com/image.jpg',
      );

      const item3 = Item(
        id: '2',
        name: 'Other Game',
        description: 'Other description',
      );

      expect(item1, equals(item2));
      expect(item1, isNot(equals(item3)));
    });

    test('should have consistent hashCode', () {
      const item1 = Item(
        id: '1',
        name: 'Test Game',
        description: 'A test game description',
        imageUrl: 'https://example.com/image.jpg',
      );

      const item2 = Item(
        id: '1',
        name: 'Test Game',
        description: 'A test game description',
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(item1.hashCode, equals(item2.hashCode));
    });

    test('should have meaningful toString', () {
      final itemString = testItem.toString();

      expect(itemString, contains('Item'));
      expect(itemString, contains('1'));
      expect(itemString, contains('Test Game'));
      expect(itemString, contains('A test game description'));
      expect(itemString, contains('https://example.com/image.jpg'));
    });
  });
}