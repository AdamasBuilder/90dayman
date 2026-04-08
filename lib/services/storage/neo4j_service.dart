import 'package:dart_neo4j/dart_neo4j.dart';

class Neo4jService {
  static Neo4jService? _instance;
  late Neo4jDriver _driver;
  bool _initialized = false;

  static const String _uri = 'neo4j+s://eee9a2de.databases.neo4j.io';
  static const String _user = 'neo4j';
  static const String _password = '_-6QPptZQ5goySH2V7oREIP7pegU6KVX14y4AN5mRzk';

  Neo4jService._();

  static Future<Neo4jService> getInstance() async {
    if (_instance == null) {
      _instance = Neo4jService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    if (_initialized) return;

    _driver = Neo4jDriver.create(
      _uri,
      auth: BasicAuth(_user, _password),
    );
    _initialized = true;
  }

  Future<void> ensureInitialized() async {
    if (!_initialized) {
      await _init();
    }
  }

  Future<void> upsertUser(
      String odlId, Map<String, dynamic> profileData) async {
    await ensureInitialized();

    final session = _driver.session();
    try {
      await session.run(
        '''
        MERGE (u:User {odlId: \$odlId})
        SET u.name = \$name,
            u.createdAt = \$createdAt,
            u.onboardingComplete = \$onboardingComplete,
            u.stoicScore = \$stoicScore,
            u.gritScore = \$gritScore,
            u.emotionRegScore = \$emotionRegScore,
            u.personalityScore = \$personalityScore,
            u.stressScore = \$stressScore,
            u.lastUpdated = timestamp()
        ''',
        {
          'odlId': odlId,
          'name': profileData['name'] ?? 'User',
          'createdAt':
              profileData['createdAt'] ?? DateTime.now().toIso8601String(),
          'onboardingComplete': profileData['onboardingComplete'] ?? false,
          'stoicScore': profileData['stoicScore'] ?? 0,
          'gritScore': profileData['gritScore'] ?? 0,
          'emotionRegScore': profileData['emotionRegScore'] ?? 0,
          'personalityScore': profileData['personalityScore'] ?? 0,
          'stressScore': profileData['stressScore'] ?? 0,
        },
      );
    } finally {
      await session.close();
    }
  }

  Future<void> saveOnboardingResponses(
      String userId, Map<String, int> responses) async {
    await ensureInitialized();

    final session = _driver.session();
    try {
      for (final entry in responses.entries) {
        await session.run(
          '''
          MATCH (u:User {odlId: \$userId})
          MERGE (q:Question {id: \$questionId})
          SET q.category = 'onboarding', q.source = 'scientific'
          MERGE (u)-[r:ANSWERED]->(q)
          SET r.level = \$level, r.timestamp = timestamp()
          ''',
          {
            'userId': userId,
            'questionId': entry.key,
            'level': entry.value,
          },
        );
      }
    } finally {
      await session.close();
    }
  }

  Future<void> saveEvent(String userId, Map<String, dynamic> eventData) async {
    await ensureInitialized();

    final session = _driver.session();
    try {
      await session.run(
        '''
        MATCH (u:User {odlId: \$userId})
        CREATE (e:Event {
          id: \$eventId,
          description: \$description,
          emotionLevel: \$emotionLevel,
          reactionLevel: \$reactionLevel,
          category: \$category,
          timestamp: \$timestamp,
          notes: \$notes
        })
        CREATE (u)-[:EXPERIENCED]->(e)
        ''',
        {
          'userId': userId,
          'eventId': eventData['id'],
          'description': eventData['description'],
          'emotionLevel': eventData['emotionLevel'],
          'reactionLevel': eventData['reactionLevel'],
          'category': eventData['category'] ?? 'general',
          'timestamp': eventData['timestamp'],
          'notes': eventData['notes'] ?? '',
        },
      );
    } finally {
      await session.close();
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String odlId) async {
    await ensureInitialized();

    final session = _driver.session();
    try {
      final result = await session.run(
        'MATCH (u:User {odlId: \$odlId}) RETURN u',
        {'odlId': odlId},
      );

      final record = await result.firstOrNull();
      if (record == null) return null;

      final node = record.getNode('u');
      return node.properties;
    } finally {
      await session.close();
    }
  }

  Future<List<Map<String, dynamic>>> getRecentEvents(String userId,
      {int limit = 10}) async {
    await ensureInitialized();

    final session = _driver.session();
    try {
      final result = await session.run(
        '''
        MATCH (u:User {odlId: \$userId})-[:EXPERIENCED]->(e:Event)
        RETURN e
        ORDER BY e.timestamp DESC
        LIMIT \$limit
        ''',
        {'userId': userId, 'limit': limit},
      );

      final events = <Map<String, dynamic>>[];
      await for (final record in result.records()) {
        final node = record.getNode('e');
        events.add(node.properties);
      }
      return events;
    } finally {
      await session.close();
    }
  }

  Future<List<Map<String, dynamic>>> findSimilarUsers(
      String odlId, Map<String, dynamic> scores) async {
    await ensureInitialized();

    final session = _driver.session();
    try {
      final result = await session.run(
        '''
        MATCH (u:User)
        WHERE u.odlId <> \$odlId
        WITH u, 
             abs(u.stoicScore - \$stoicScore) + 
             abs(u.gritScore - \$gritScore) +
             abs(u.emotionRegScore - \$emotionRegScore) +
             abs(u.stressScore - \$stressScore) AS distance
        RETURN u
        ORDER BY distance ASC
        LIMIT 5
        ''',
        {
          'odlId': odlId,
          'stoicScore': scores['stoicScore'] ?? 0,
          'gritScore': scores['gritScore'] ?? 0,
          'emotionRegScore': scores['emotionRegScore'] ?? 0,
          'stressScore': scores['stressScore'] ?? 0,
        },
      );

      final users = <Map<String, dynamic>>[];
      await for (final record in result.records()) {
        final node = record.getNode('u');
        users.add(node.properties);
      }
      return users;
    } finally {
      await session.close();
    }
  }

  Future<List<Map<String, dynamic>>> getPatterns(String odlId) async {
    await ensureInitialized();

    final session = _driver.session();
    try {
      final result = await session.run(
        '''
        MATCH (u:User {odlId: \$odlId})-[:EXPERIENCED]->(e:Event)
        WITH e.category AS category, 
             avg(e.emotionLevel) AS avgEmotion, 
             avg(e.reactionLevel) AS avgReaction,
             count(*) AS eventCount
        WHERE eventCount >= 3
        RETURN category, avgEmotion, avgReaction, eventCount
        ORDER BY eventCount DESC
        ''',
        {'odlId': odlId},
      );

      final patterns = <Map<String, dynamic>>[];
      await for (final record in result.records()) {
        patterns.add({
          'category': record.getString('category'),
          'avgEmotion': record.getDouble('avgEmotion'),
          'avgReaction': record.getDouble('avgReaction'),
          'eventCount': record.getInt('eventCount'),
        });
      }
      return patterns;
    } finally {
      await session.close();
    }
  }

  Future<void> close() async {
    if (_initialized) {
      await _driver.close();
      _initialized = false;
    }
  }
}
