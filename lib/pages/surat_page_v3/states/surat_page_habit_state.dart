class SuratPageHabitState {
  const SuratPageHabitState({
    this.isRecording = false,
    this.recordedPagesAsRead = 0,
    this.isOnReadCTAVisible = true,
    this.isHabitDailySummaryChanged = false,
    this.showMinimizedAudioPlayer = false,
  });

  final bool isRecording;
  final int recordedPagesAsRead;
  final bool isOnReadCTAVisible;
  final bool isHabitDailySummaryChanged;
  final bool showMinimizedAudioPlayer;

  SuratPageHabitState copyWith({
    bool? isRecording,
    int? recordedPagesAsRead,
    bool? isOnReadCTAVisible,
    bool? isHabitDailySummaryChanged,
    bool? showMinimizedAudioPlayer,
  }) {
    return SuratPageHabitState(
      isRecording: isRecording ?? this.isRecording,
      recordedPagesAsRead: recordedPagesAsRead ?? this.recordedPagesAsRead,
      isOnReadCTAVisible: isOnReadCTAVisible ?? this.isOnReadCTAVisible,
      isHabitDailySummaryChanged:
          isHabitDailySummaryChanged ?? this.isHabitDailySummaryChanged,
      showMinimizedAudioPlayer:
          showMinimizedAudioPlayer ?? this.showMinimizedAudioPlayer,
    );
  }
}
