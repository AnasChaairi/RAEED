import '../../../core/network/api_envelope.dart';
import 'child.dart';
import 'child_detail.dart';

/// Reads children, scoped server-side.
///
/// The interface deliberately takes no role and no "which children" argument
/// beyond an optional group filter: `GET /children` already returns "own
/// children / own groups / all" per `specs/05-authorization.md`, resolved from
/// the caller's token against live `parent_child` / `group_educator` rows. A
/// client-supplied scope parameter would be a scope the client could get wrong
/// — and an invitation to trust it.
abstract interface class ChildrenRepository {
  /// One page of the children the caller may see.
  ///
  /// [cursor] continues a previous page; [groupId] narrows to one group, for
  /// the educator's group view.
  Future<Paginated<Child>> fetchChildren({String? cursor, String? groupId});

  /// One child's full profile.
  ///
  /// Throws `ApiException` with `scope.forbidden` when the child is outside
  /// the caller's scope — which the UI renders as "not available to you",
  /// never as "not found", so the two stay distinguishable.
  Future<ChildDetail> fetchChild(String childId);
}
