import '../../domain/entities/legal_case.dart';

class LegalCaseModel {
  final int id;
  final String areaDireito;
  final String pedidosPrincipais;
  final String tesePretendida;
  final String uf;
  final String? fatosEstruturados;
  final String? fundamentosJuridicos;
  final int? tribunalPrecedenteId;
  final DateTime createdAt;
  final int usuarioId;

  LegalCaseModel({
    required this.id,
    required this.areaDireito,
    required this.pedidosPrincipais,
    required this.tesePretendida,
    required this.uf,
    this.fatosEstruturados,
    this.fundamentosJuridicos,
    this.tribunalPrecedenteId,
    required this.createdAt,
    required this.usuarioId,
  });

  factory LegalCaseModel.fromJson(Map<String, dynamic> json) {
    return LegalCaseModel(
      id: _readInt(json, ['id'])!,
      areaDireito: _readString(json, ['area_direito', 'areaDireito'])!,
      pedidosPrincipais: _readString(json, [
        'pedidos_principais',
        'pedidosPrincipais',
      ])!,
      tesePretendida: _readString(json, ['tese_pretendida', 'tesePretendida'])!,
      uf: _readString(json, ['uf'])!,
      fatosEstruturados: json['fatos_estruturados'] as String?,
      fundamentosJuridicos: json['fundamentos_juridicos'] as String?,
      tribunalPrecedenteId: _readInt(json, [
        'tribunalPrecedenteId',
        'tribunal_precedente_id',
      ]),
      createdAt: DateTime.parse(
        _readString(json, ['createdAt', 'created_at'])!,
      ),
      usuarioId: _readInt(json, ['usuarioId', 'usuario_id'])!,
    );
  }

  LegalCase toEntity() {
    return LegalCase(
      id: id,
      areaDireito: areaDireito,
      pedidosPrincipais: pedidosPrincipais,
      tesePretendida: tesePretendida,
      uf: uf,
      fatosEstruturados: fatosEstruturados,
      fundamentosJuridicos: fundamentosJuridicos,
      tribunalPrecedenteId: tribunalPrecedenteId,
      createdAt: createdAt,
      usuarioId: usuarioId,
    );
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value != null) {
        final parsed = int.tryParse(value.toString());
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }
}
