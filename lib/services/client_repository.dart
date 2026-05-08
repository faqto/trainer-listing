import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/client_model.dart';
import 'auth_repository.dart';

abstract class ClientRepository {
  static ClientRepository instance = FirestoreClientRepository();

  Future<List<Client>> get clients;

  Future<Client?> getById(String id);

  Future<void> addClient(Client client);

  Future<void> updateClient(Client client);

  Future<void> deleteClient(String id);

  Future<void> resetForTesting();

  String createClientId();
}

class FirestoreClientRepository implements ClientRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _clientsCollection {
    final userId = AuthRepository.instance.currentUserId;
    if (userId == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unauthenticated',
        message: 'Please sign in before loading clients.',
      );
    }

    return _firestore.collection('users').doc(userId).collection('clients');
  }

  @override
  Future<List<Client>> get clients async {
    final snapshot = await _clientsCollection.get();
    return snapshot.docs
        .map((doc) => Client.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Client?> getById(String id) async {
    final doc = await _clientsCollection.doc(id).get();
    if (doc.exists) {
      return Client.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> addClient(Client client) async {
    await _clientsCollection.doc(client.id).set(client.toMap());
  }

  @override
  Future<void> updateClient(Client client) async {
    await _clientsCollection.doc(client.id).update(client.toMap());
  }

  @override
  Future<void> deleteClient(String id) async {
    await _clientsCollection.doc(id).delete();
  }

  @override
  Future<void> resetForTesting() async {
    // No-op for Firestore-backed repository. Use Firestore emulator or
    // a separate test setup if real test isolation is required.
  }

  @override
  String createClientId() {
    return _clientsCollection.doc().id;
  }
}
