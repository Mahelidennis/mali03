class MaliVibe {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String color;
  final bool isSelected;

  const MaliVibe({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    this.isSelected = false,
  });

  MaliVibe copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    String? color,
    bool? isSelected,
  }) {
    return MaliVibe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'emoji': emoji,
      'color': color,
      'isSelected': isSelected,
    };
  }

  factory MaliVibe.fromJson(Map<String, dynamic> json) {
    return MaliVibe(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '',
      color: json['color'] ?? '',
      isSelected: json['isSelected'] ?? false,
    );
  }
}

class OnboardingState {
  final bool hasCompletedWelcome;
  final String? selectedVibeId;
  final bool hasAcceptedPermissions;
  final bool hasCompletedOnboarding;

  const OnboardingState({
    this.hasCompletedWelcome = false,
    this.selectedVibeId,
    this.hasAcceptedPermissions = false,
    this.hasCompletedOnboarding = false,
  });

  OnboardingState copyWith({
    bool? hasCompletedWelcome,
    String? selectedVibeId,
    bool? hasAcceptedPermissions,
    bool? hasCompletedOnboarding,
  }) {
    return OnboardingState(
      hasCompletedWelcome: hasCompletedWelcome ?? this.hasCompletedWelcome,
      selectedVibeId: selectedVibeId ?? this.selectedVibeId,
      hasAcceptedPermissions: hasAcceptedPermissions ?? this.hasAcceptedPermissions,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasCompletedWelcome': hasCompletedWelcome,
      'selectedVibeId': selectedVibeId,
      'hasAcceptedPermissions': hasAcceptedPermissions,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      hasCompletedWelcome: json['hasCompletedWelcome'] ?? false,
      selectedVibeId: json['selectedVibeId'],
      hasAcceptedPermissions: json['hasAcceptedPermissions'] ?? false,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    );
  }
}
