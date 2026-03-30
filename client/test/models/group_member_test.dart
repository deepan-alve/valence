import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/group_member.dart';

void main() {
  group('MemberStatus', () {
    test('all values exist', () {
      expect(MemberStatus.values.length, 4);
      expect(MemberStatus.values, contains(MemberStatus.allDone));
      expect(MemberStatus.values, contains(MemberStatus.partial));
      expect(MemberStatus.values, contains(MemberStatus.notStarted));
      expect(MemberStatus.values, contains(MemberStatus.inactive));
    });
  });

  group('GroupMember', () {
    test('constructs with required fields', () {
      const member = GroupMember(
        id: 'u1',
        name: 'Nitil',
        avatarUrl: null,
        habitsCompleted: 5,
        habitsTotal: 5,
        status: MemberStatus.allDone,
        isCurrentUser: false,
      );

      expect(member.id, 'u1');
      expect(member.name, 'Nitil');
      expect(member.habitsCompleted, 5);
      expect(member.status, MemberStatus.allDone);
    });

    test('initials returns first two characters of name uppercased', () {
      const member = GroupMember(
        id: 'u1',
        name: 'Nitil',
        avatarUrl: null,
        habitsCompleted: 5,
        habitsTotal: 5,
        status: MemberStatus.allDone,
        isCurrentUser: false,
      );

      expect(member.initials, 'NI');
    });

    test('initials handles single-char names', () {
      const member = GroupMember(
        id: 'u2',
        name: 'X',
        avatarUrl: null,
        habitsCompleted: 0,
        habitsTotal: 3,
        status: MemberStatus.notStarted,
        isCurrentUser: false,
      );

      expect(member.initials, 'X');
    });

    test('initials handles empty name', () {
      const member = GroupMember(
        id: 'u9',
        name: '',
        avatarUrl: null,
        habitsCompleted: 0,
        habitsTotal: 3,
        status: MemberStatus.notStarted,
        isCurrentUser: false,
      );

      expect(member.initials, '?');
    });

    test('isComplete returns true when all habits done', () {
      const member = GroupMember(
        id: 'u1',
        name: 'Diana',
        avatarUrl: null,
        habitsCompleted: 6,
        habitsTotal: 6,
        status: MemberStatus.allDone,
        isCurrentUser: true,
      );

      expect(member.isComplete, isTrue);
    });

    test('isComplete returns false when partial', () {
      const member = GroupMember(
        id: 'u3',
        name: 'Ava',
        avatarUrl: null,
        habitsCompleted: 3,
        habitsTotal: 5,
        status: MemberStatus.partial,
        isCurrentUser: false,
      );

      expect(member.isComplete, isFalse);
    });

    test('isComplete returns false when habitsTotal is 0', () {
      const member = GroupMember(
        id: 'u7',
        name: 'Ghost',
        avatarUrl: null,
        habitsCompleted: 0,
        habitsTotal: 0,
        status: MemberStatus.inactive,
        isCurrentUser: false,
      );

      expect(member.isComplete, isFalse);
    });

    test('progressLabel returns fraction string', () {
      const member = GroupMember(
        id: 'u3',
        name: 'Ava',
        avatarUrl: null,
        habitsCompleted: 3,
        habitsTotal: 5,
        status: MemberStatus.partial,
        isCurrentUser: false,
      );

      expect(member.progressLabel, '3/5');
    });

    test('copyWith overrides specified fields', () {
      const member = GroupMember(
        id: 'u1',
        name: 'Nitil',
        avatarUrl: null,
        habitsCompleted: 3,
        habitsTotal: 5,
        status: MemberStatus.partial,
        isCurrentUser: false,
      );

      final updated = member.copyWith(
        habitsCompleted: 5,
        status: MemberStatus.allDone,
      );

      expect(updated.habitsCompleted, 5);
      expect(updated.status, MemberStatus.allDone);
      expect(updated.name, 'Nitil'); // unchanged
    });

    test('copyWith preserves avatarUrl when not specified', () {
      const member = GroupMember(
        id: 'u1',
        name: 'Nitil',
        avatarUrl: 'https://example.com/avatar.png',
        habitsCompleted: 3,
        habitsTotal: 5,
        status: MemberStatus.partial,
        isCurrentUser: false,
      );

      final updated = member.copyWith(habitsCompleted: 5);
      expect(updated.avatarUrl, 'https://example.com/avatar.png');
    });
  });
}
