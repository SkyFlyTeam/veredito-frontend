# Guia de Implementação RBAC (Role-Based Access Control)

Este documento descreve a estratégia de controle de acesso baseada em funções (roles) implementada no projeto Veredito. A abordagem foca em centralização, legibilidade e facilidade de manutenção.

## 1. Centralização de Lógica na Entidade de Usuário

Para evitar o uso de strings soltas (`'juiz'`, `'advogado'`) espalhadas por toda a aplicação, utilizamos **Extensions** do Dart na entidade `User`. Isso garante que a lógica de identificação de papéis esteja em um único lugar.

**Arquivo:** `lib/features/account/domain/entities/user.dart`

```dart
class User {
  final String role; // Recebido do backend: 'juiz', 'advogado' ou 'user'
  // ... outros campos (nome, email, etc)
}

extension UserRoleX on User {
  bool get isJuiz => role.toLowerCase() == 'juiz';
  bool get isAdvogado => role.toLowerCase() == 'advogado';
  bool get isUser => role.toLowerCase() == 'user';
}
```

---

## 2. Roteamento Condicional no AppRouter

O roteador principal utiliza as extensões definidas acima para decidir dinamicamente quais itens exibir na barra de navegação e quais telas devem ser carregadas.

### Itens do Menu (Bottom Navigation)
**Arquivo:** `lib/routes/app_router.dart`

```dart
static List<AppBottomNavItem> getHomeBottomItems(User? user) {
  final List<AppBottomNavItem> items = [];

  // Item comum a todos
  items.add(AppBottomNavItem(label: 'Home', icon: Icons.home, route: '/home'));

  // Itens condicionais baseados no cargo
  if (user?.isJuiz ?? false) {
    items.add(const AppBottomNavItem(label: 'Processos', icon: Icons.gavel, route: '/history'));
  } else if (user?.isAdvogado ?? false) {
    items.add(const AppBottomNavItem(label: 'Petições', icon: Icons.description, route: '/history'));
  }

  items.add(const AppBottomNavItem(label: 'Perfil', icon: Icons.person, route: '/profile'));
  return items;
}
```

### Seleção de Telas no IndexedStack
As telas da Home são alternadas dinamicamente no shell principal da aplicação:

```dart
List<Widget> _getScreens(User? user) {
  final List<Widget> screens = [];

  // Seleção da tela de Home por perfil
  if (user?.isJuiz ?? false) {
    screens.add(const JuizHomeScreen());
  } else if (user?.isAdvogado ?? false) {
    screens.add(const AdvogadoHomeScreen());
  } else {
    screens.add(const UserHomeScreen());
  }

  // ... outras telas compartilhadas
  return screens;
}
```

---

## 3. Modularização das Telas de Home

Em vez de uma única tela complexa cheia de condicionais, dividimos a interface em arquivos específicos por papel. Isso permite que cada perfil tenha saudações e funcionalidades exclusivas de forma limpa.

### Exemplo: `JuizHomeScreen`
Cada tela de Home consome o `sessionProvider` para obter os dados do usuário logado e aplica a interface necessária.

```dart
class JuizHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa apenas a sessão para a saudação
    final user = ref.watch(sessionProvider);
    
    return Column(
      children: [
        Text('Olá, ${user?.nome} Juiz!'),
        // O card gerencia seu próprio estado de upload internamente
        CommonUploadCard(title: 'Analisar Processo'),
      ],
    );
  }
}
```

---

## 4. Boa Prática: Isolamento de Estado

Uma lição importante aprendida nesta implementação é o **Isolamento de Estado de Alta Frequência**.

### O Problema
Se uma tela pai (como a `JuizHomeScreen`) observar um provider que muda constantemente (como o progresso de um upload), ela será reconstruída por inteira a cada 1% de progresso. Isso pode causar:
1. Perda de foco em campos de texto.
2. Interrupção de animações.
3. Reinicialização indesejada de componentes filhos.

### A Solução
Componentes que gerenciam processos complexos (Upload, Streams, Timers) devem:
1. Ser `ConsumerStatefulWidget` (ou usar `Consumer` interno).
2. Observar os seus respectivos providers **dentro** do próprio componente.
3. Evitar passar estados voláteis via construtor do pai para o filho.

---

## 5. Como expandir para novos cargos
1.  Adicione o novo cargo (ex: `isAdministrador`) na extensão `UserRoleX` em `user.dart`.
2.  Crie a nova tela de interface na pasta correspondente ao cargo.
3.  Atualize o `AppRouter.dart` (métodos `getHomeBottomItems` e `_getScreens`) para incluir a nova lógica de exibição.
