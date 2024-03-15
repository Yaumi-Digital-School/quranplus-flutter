enum StoredIcon {
  iconForm(path: 'images/icon_form.png'),
  iconBookmark(path: 'images/icon_bookmark.png'),
  iconFavorite(path: 'images/icon_favorite.png'),
  iconCollaborate(path: 'images/icon_collaborate.png'),
  iconGoogle(path: 'images/icon_google.png'),
  iconApple(path: 'images/icon_apple.png'),
  iconAccount(path: 'images/svg/icon-account.svg'),
  iconLogout(path: 'images/svg/logout-icon.svg'),
  iconSync(path: 'images/icon_sync.png'),
  iconUpdateNow(path: 'images/icon_update_now.png'),
  iconFavoriteInactive(path: 'images/icon_favorite_inactive.png'),
  iconNoWifi(path: 'images/icon_no_wifi.png'),
  iconRefresh(path: 'images/icon_refresh.png'),
  iconChecklistCheck(path: 'images/icon_checklist_check.png'),
  iconHabitArrow(path: 'images/icon_habit_arrow.png'),
  iconGroupMember(path: 'images/icon_group_member.png'),
  iconLeaveGroup(path: 'images/icon_leave_group.png'),
  iconInviteMember(path: 'images/icon_invite_member.png'),
  iconEditSquare(path: 'images/icon_edit_square.png'),
  iconTheme(path: 'images/svg/theme-icon.svg'),
  iconSunClock(path: 'images/svg/sun-clock.svg'),
  iconQuranPlus(path: 'images/svg/logo-quran-plus.svg'),
  iconFajrTime(path: 'images/svg/icon_fajr_times.svg'),
  iconDhuhrTime(path: 'images/svg/icon_dhuhr_time.svg'),
  iconAsrTime(path: 'images/svg/icon_asr_time.svg'),
  iconMagribTime(path: 'images/svg/Icon_isya&magrib_times.svg'),
  iconIsyaTime(path: 'images/svg/Icon_isya&magrib_times.svg'),
  iconLocation(path: 'images/svg/location.svg'),
  iconArrowRight(path: 'images/svg/arrow-right.svg');

  const StoredIcon({required this.path});

  final String path;
}
