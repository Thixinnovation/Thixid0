class NetworkConnection {
  final String id;
  final String name;
  final String? avatar;
  final String title;
  final int mutualConnections;
  final String? status; // pending, accepted, rejected
  final DateTime? connectedAt;

  NetworkConnection({
    required this.id,
    required this.name,
    this.avatar,
    required this.title,
    required this.mutualConnections,
    this.status,
    this.connectedAt,
  });

  factory NetworkConnection.fromJson(Map<String, dynamic> json) {
    return NetworkConnection(
      id: json['id'],
      name: json['display_name'] ?? json['name'] ?? 'Utilisateur',
      avatar: json['avatar_url'] ?? json['avatar'],
      title: json['title'] ?? 'Membre THIX',
      mutualConnections: json['mutual_connections'] ?? json['mutualConnections'] ?? 0,
      status: json['status'],
      connectedAt: json['connected_at'] != null 
          ? DateTime.tryParse(json['connected_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'display_name': name,
    'avatar_url': avatar,
    'title': title,
    'mutual_connections': mutualConnections,
    'status': status,
    'connected_at': connectedAt?.toIso8601String(),
  };

  NetworkConnection copyWith({
    String? id,
    String? name,
    String? avatar,
    String? title,
    int? mutualConnections,
    String? status,
    DateTime? connectedAt,
  }) {
    return NetworkConnection(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      title: title ?? this.title,
      mutualConnections: mutualConnections ?? this.mutualConnections,
      status: status ?? this.status,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }
}

class ConnectionRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final String? requesterAvatar;
  final String requesterTitle;
  final DateTime createdAt;

  ConnectionRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    this.requesterAvatar,
    required this.requesterTitle,
    required this.createdAt,
  });

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    final requester = json['requester'] as Map<String, dynamic>?;
    
    return ConnectionRequest(
      id: json['id'],
      requesterId: requester?['id'] ?? json['requester_id'],
      requesterName: requester?['display_name'] ?? 'Utilisateur',
      requesterAvatar: requester?['avatar_url'],
      requesterTitle: requester?['title'] ?? 'Membre THIX',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
