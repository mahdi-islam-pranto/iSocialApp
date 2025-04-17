import 'dart:developer';

class AgentListResponse {
  String? status;
  List<AgentData>? data;

  AgentListResponse({this.status, this.data});

  AgentListResponse.fromJson(Map<String, dynamic> json) {
    try {
      status = json['status']?.toString();
      log('Parsing status: $status');

      if (json['data'] != null) {
        log('Data is not null, type: ${json['data'].runtimeType}');

        // Handle both success and error cases
        if (status == "200" && json['data'] is List) {
          log('Data is a list with ${json['data'].length} items');
          data = <AgentData>[];
          json['data'].forEach((v) {
            try {
              data!.add(AgentData.fromJson(v));
            } catch (e) {
              log('Error parsing agent data: $e');
            }
          });
          log('Successfully parsed ${data!.length} agents');
        } else if (json['data'] is String) {
          // This is an error message
          log('Error message in data field: ${json['data']}');
          data = <AgentData>[]; // Initialize with empty list
        } else {
          log('WARNING: Unexpected data format: ${json['data'].runtimeType}');
          data = <AgentData>[]; // Initialize with empty list
        }
      } else {
        log('Data is null in the response');
        data = <AgentData>[]; // Initialize with empty list
      }
    } catch (e, stackTrace) {
      log('Error parsing AgentListResponse: $e');
      log('Stack trace: $stackTrace');
      data = <AgentData>[]; // Initialize with empty list in case of error
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AgentData {
  String? username;
  String? status;
  String? email;
  String? fullName;
  String? role;

  AgentData({this.username, this.status, this.email, this.fullName, this.role});

  AgentData.fromJson(Map<String, dynamic> json) {
    try {
      username = json['username']?.toString();
      status = json['status']?.toString();
      email = json['email']?.toString();
      fullName = json['full_name']?.toString();
      role = json['role']?.toString();

      log('Parsed agent: $username, $fullName, $role');
    } catch (e) {
      log('Error parsing individual agent data: $e');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['status'] = status;
    data['email'] = email;
    data['full_name'] = fullName;
    data['role'] = role;
    return data;
  }

  @override
  String toString() {
    return 'AgentData{username: $username, fullName: $fullName, role: $role}';
  }
}
