// lib/features/exams/screens/edit_answers_screen.dart
import 'package:flutter/material.dart';
import '../../answer_sheet/screens/review_answer_sheet_screen.dart';

class EditAnswersScreen extends StatefulWidget {
  final String studentName;
  final String examName;
  final List<String?> answers;
  final List<bool> editedQuestions;
  final int numberOfQuestions;
  final Function(List<String?>) onAnswersUpdated;

  const EditAnswersScreen({
    super.key,
    required this.studentName,
    required this.examName,
    required this.answers,
    required this.editedQuestions,
    required this.numberOfQuestions,
    required this.onAnswersUpdated,
  });

  @override
  State<EditAnswersScreen> createState() => _EditAnswersScreenState();
}

class _EditAnswersScreenState extends State<EditAnswersScreen> {
  late List<String?> _editedAnswers;
  late List<bool> _locallyEdited;
  late List<String> options;

  // Controlar quais questões têm erro de validação
  late List<bool> _validationErrors;

  @override
  void initState() {
    super.initState();
    // Definir opções baseado no número de questões
    if (widget.numberOfQuestions == 20) {
      options = ['A', 'B', 'C', 'D', 'E'];
    } else {
      options = ['A', 'B', 'C', 'D'];
    }

    // Copiar as respostas para edição
    _editedAnswers = List.from(widget.answers);
    _locallyEdited = List.from(widget.editedQuestions);

    // Inicializar lista de erros de validação
    _validationErrors = List.filled(_editedAnswers.length, false);
  }

  /// Verifica se todas as questões com "?" foram editadas
  bool _validateAllQuestions() {
    bool isValid = true;

    for (int i = 0; i < _editedAnswers.length; i++) {
      final originalAnswer = widget.answers[i];
      final wasEdited = _locallyEdited[i];

      // Se a resposta original era null (não identificada/"?")
      // E o usuário não editou esta questão
      // Então é um erro
      if (originalAnswer == null && !wasEdited) {
        _validationErrors[i] = true;
        isValid = false;
      } else {
        _validationErrors[i] = false;
      }
    }

    setState(() {});
    return isValid;
  }

  /// Verifica se houve alguma edição
  bool _hasAnyEdit() {
    return _locallyEdited.any((edited) => edited == true);
  }

  // Mostra modal de confirmação ao tentar voltar sem salvar
  Future<bool> _showBackConfirmationDialog() async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xffe5edfa),
          title: Row(
            children: const [
              Icon(
                Icons.warning_amber_rounded,
                size: 28,
                color: Colors.orange,
              ),
              SizedBox(width: 10),
              Text(
                "Atenção!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "As respostas não foram salvas.",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              Text(
                "Você quer voltar mesmo assim?",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey, thickness: 1, height: 1),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          actionsPadding: EdgeInsets.zero,
          actions: [
            // Container para garantir largura total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  // Botão "Continuar editando" - LARANJA
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Continuar editando",                        
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botão "Voltar sem salvar" - AZUL
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff004aad),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Voltar sem salvar",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ) ??
      false;
}

  void _saveAndReview() {
    // Validar antes de salvar
    if (!_validateAllQuestions()) {
      // Mostrar snackbar com erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Corrija as questões destacadas em vermelho antes de salvar!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Rolar automaticamente para a primeira questão com erro
      _scrollToFirstError();
      return;
    }

    // Atualizar as respostas no controller
    widget.onAnswersUpdated(_editedAnswers);

    // Navegar diretamente para a tela de revisão
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewAnswerSheetScreen(
          studentName: widget.studentName,
          examName: widget.examName,
          answers: _editedAnswers,
          numberOfQuestions: widget.numberOfQuestions,
        ),
      ),
    );
  }

  /// Função para lidar com o pressionar do botão Voltar (AppBar)
  Future<bool> _onWillPop() async {
    // Se não houve edição, pode voltar sem perguntar
    if (!_hasAnyEdit()) {
      return true;
    }

    // Se houve edição, mostra modal de confirmação
    return await _showBackConfirmationDialog();
  }

  /// Rola a lista para a primeira questão com erro
  void _scrollToFirstError() {
    final firstErrorIndex = _validationErrors.indexWhere(
      (error) => error == true,
    );
    if (firstErrorIndex != -1) {
      // Usar um ScrollController para rolar até o item com erro
      // Por enquanto, apenas mostramos o snackbar
      print("Primeiro erro no índice: $firstErrorIndex");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Editar respostas"),
          backgroundColor: const Color(0xff004aad),
          foregroundColor: Colors.white,
          // O botão de voltar padrão já chamará o WillPopScope
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Card com informações do aluno e exame
              Card(
                elevation: 2,
                color: const Color(0xffe5edfa),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Estudante",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.studentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Avaliação",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.examName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Lista de questões com botão no final
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _editedAnswers.length + 1,
                  itemBuilder: (context, index) {
                    // Se for o último item, mostrar os botões
                    if (index == _editedAnswers.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            // Botão Voltar (antigo Cancelar)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  // Se houve edição, mostra modal
                                  if (_hasAnyEdit()) {
                                    final shouldGoBack =
                                        await _showBackConfirmationDialog();
                                    if (shouldGoBack) {
                                      Navigator.pop(context);
                                    }
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                                icon: const Icon(Icons.arrow_back),
                                label: const Text(
                                  "Voltar",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xff004aad),
                                  side: const BorderSide(
                                    color: Color(0xff004aad),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Botão Salvar
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveAndReview,
                                icon: const Icon(
                                  Icons.save,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Salvar",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final questionNumber = index + 1;
                    final selectedOption = _editedAnswers[index];
                    final wasEdited = _locallyEdited[index];
                    final hasError = _validationErrors[index];

                    return Card(
                      color: const Color(0xffe5edfa),
                      margin: const EdgeInsets.only(bottom: 12),
                      // Adicionar borda vermelha se houver erro
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: hasError
                            ? const BorderSide(color: Colors.red, width: 2)
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Número da questão com indicadores
                            Row(
                              children: [
                                Text(
                                  "Questão $questionNumber",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: wasEdited
                                        ? Colors.orange
                                        : (hasError
                                              ? Colors.red
                                              : Colors.black),
                                  ),
                                ),
                                if (wasEdited) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Editada",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                if (hasError) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Obrigatória",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            if (hasError) ...[
                              const SizedBox(height: 8),
                              Text(
                                "Esta questão não foi identificada. Selecione uma resposta abaixo.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Opções A, B, C, D, E (círculos)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: options.map((option) {
                                final isSelected = selectedOption == option;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _editedAnswers[index] = null;
                                      } else {
                                        _editedAnswers[index] = option;
                                      }
                                      _locallyEdited[index] = true;
                                      // Limpar erro de validação quando editar
                                      if (_validationErrors[index]) {
                                        _validationErrors[index] = false;
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.grey[600]
                                          : Colors.grey[200],
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.grey[600]!
                                            : (hasError && !wasEdited
                                                  ? Colors.red
                                                  : Colors.grey[400]!),
                                        width:
                                            hasError &&
                                                !wasEdited &&
                                                !isSelected
                                            ? 2
                                            : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 20),

                            // Botões Em branco e Marcação Dupla
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (selectedOption == "Em branco") {
                                          _editedAnswers[index] = null;
                                        } else {
                                          _editedAnswers[index] = "Em branco";
                                        }
                                        _locallyEdited[index] = true;
                                        // Limpar erro de validação quando editar
                                        if (_validationErrors[index]) {
                                          _validationErrors[index] = false;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selectedOption == "Em branco"
                                            ? Colors.grey[600]
                                            : Colors.grey[200],
                                        border: Border.all(
                                          color: selectedOption == "Em branco"
                                              ? Colors.grey[600]!
                                              : (hasError && !wasEdited
                                                    ? Colors.red
                                                    : Colors.grey[400]!),
                                          width:
                                              hasError &&
                                                  !wasEdited &&
                                                  selectedOption != "Em branco"
                                              ? 2
                                              : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Em branco",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: selectedOption == "Em branco"
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (selectedOption ==
                                            "Marcação dupla") {
                                          _editedAnswers[index] = null;
                                        } else {
                                          _editedAnswers[index] =
                                              "Marcação dupla";
                                        }
                                        _locallyEdited[index] = true;
                                        // Limpar erro de validação quando editar
                                        if (_validationErrors[index]) {
                                          _validationErrors[index] = false;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            selectedOption == "Marcação dupla"
                                            ? Colors.grey[600]
                                            : Colors.grey[200],
                                        border: Border.all(
                                          color:
                                              selectedOption == "Marcação dupla"
                                              ? Colors.grey[600]!
                                              : (hasError && !wasEdited
                                                    ? Colors.red
                                                    : Colors.grey[400]!),
                                          width:
                                              hasError &&
                                                  !wasEdited &&
                                                  selectedOption !=
                                                      "Marcação dupla"
                                              ? 2
                                              : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Marcação dupla",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                selectedOption ==
                                                    "Marcação dupla"
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
