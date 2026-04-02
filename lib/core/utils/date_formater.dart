/// Formats a [DateTime] object into a string in the format "dd/MM/yyyy".
///
/// Returns a string representation of the date in the specified format.
String dateToLocalString(DateTime date) {

  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}