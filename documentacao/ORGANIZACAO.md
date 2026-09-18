# Organização dos arquivos — adaptação do PW

## Padrões aproveitados do projeto enviado

| No PW enviado | Nesta adaptação |
|---|---|
| `view/admin.php` seleciona a tela | A entrada permanece `view/admin.php`, com parâmetro numérico `link` e lista fixa de telas permitidas. |
| `view/menu.php` concentra a navegação | O menu do VetData fica no mesmo caminho. |
| `model/estado.php` e `model/usuario.php` definem classes | `model/animal.php`, `model/responsavel.php` e as demais entidades têm atributos privados, construtor e getters. |
| Controllers específicos de inserção e alteração | Há um arquivo por operação, como `atendimentoInserir.php`, `atendimentoAlterar.php` e `atendimentoCancelar.php`. |
| DAOs recebem os objetos | `AnimalDAO::salvar(Animal $animal)` e os demais DAOs recebem objetos ou parâmetros validados. |
| `persist/conexao.php` fornece o PDO | A classe `Conexao` mantém esse papel; os valores editáveis ficam em `persist/config.php`. |
| `view/css` e `view/js` guardam os recursos | As mesmas pastas são usadas, com `img` e `fonts` para os recursos locais. |
| `script.sql` instala o banco | O arquivo na raiz instala o banco veterinário `vetdata`. |

As tabelas de Estado e Usuario eram exemplos do projeto original; elas não fazem parte do domínio veterinário desta entrega. Não foi necessário alterar o esquema do VetData anterior.

## Arquivos por módulo

| Módulo | Telas e formulários em `view/` | Controllers principais em `controller/` | Persistência |
|---|---|---|---|
| Visão geral | `inicio.php` | `prepararDados.php` | `painelDAO.php` |
| Pacientes | `animalListar.php`, `animalFormulario.php`, `animalProntuario.php` | `animalSalvar.php`, `animalArquivar.php`, `animalReativar.php` | `animalDAO.php` |
| Responsáveis | `responsavelListar.php`, `responsavelFormulario.php` | `responsavelSalvar.php`, `responsavelInativar.php` | `responsavelDAO.php` |
| Equipe | `veterinarioListar.php`, `veterinarioInserir.php`, `disponibilidadeInserir.php` | `veterinarioInserir.php`, `disponibilidadeInserir.php` | `veterinarioDAO.php` |
| Agenda | `atendimentoListar.php`, `atendimentoInserir.php`, `atendimentoAlterar.php`, `atendimentoCancelar.php` | `atendimentoInserir.php`, `atendimentoAlterar.php`, `atendimentoConfirmar.php`, `atendimentoCancelar.php` | `atendimentoDAO.php` |
| Atendimento | `atendimentoDetalhar.php`, `registroClinicoInserir.php`, `prescricaoInserir.php` | `registroClinicoInserir.php`, `prescricaoInserir.php`, `atendimentoConcluir.php` | `clinicoDAO.php`, `atendimentoDAO.php` |
| Serviços | `servicoInserir.php` | `servicoInserir.php` | `servicoDAO.php` |
| Exames | `exameListar.php`, `exameInserir.php`, `exameResultadoInserir.php` | `exameInserir.php`, `exameColetar.php`, `exameResultadoInserir.php` | `exameDAO.php` |
| Vacinação | `vacinacaoListar.php`, `vacinacaoInserir.php` | `vacinacaoInserir.php` | `vacinaDAO.php` |
| Financeiro | `financeiroListar.php`, `cobrancaInserir.php`, `pagamentoInserir.php` | `cobrancaInserir.php`, `pagamentoInserir.php` | `financeiroDAO.php` |

`animalSalvar.php` e `responsavelSalvar.php` atendem inclusão e edição: id vazio cria um registro; id preenchido altera o registro selecionado. Por isso cada um usa um formulário compartilhado, sem duplicar os campos.

## Exemplo: salvar um paciente

1. `view/animalListar.php` mostra os pacientes e abre o formulário `view/animalFormulario.php`.
2. O formulário envia um POST para `controller/animalSalvar.php` com os campos e o token da sessão.
3. O controller valida os campos por meio de `model/entrada.php` e constrói um objeto `Animal`, definido em `model/animal.php`.
4. `persist/animalDAO.php` recebe o objeto e executa um INSERT ou UPDATE com parâmetros preparados. A conexão vem de `persist/conexao.php`.
5. `controller/base.php` guarda a mensagem e redireciona para `view/admin.php?link=2`. Se houver erro, volta à origem e recupera os valores no formulário.

As views chamam métodos de leitura dos DAOs, mas não contêm comandos SQL. Os DAOs não acessam `$_POST`, não imprimem HTML e não fazem redirecionamentos. O controller organiza a operação; as regras relacionais e clínicas permanecem também protegidas no banco.

## Rotas de navegação

| `link` | Tela |
|---|---|
| 0 | Visão geral |
| 1 | Agenda |
| 2 | Pacientes |
| 3 | Responsáveis |
| 4 | Equipe |
| 5 | Exames |
| 6 | Vacinação |
| 7 | Financeiro |
| 8 | Prontuário, com `&id=ID_DO_ANIMAL` |
| 9 | Atendimento, com `&id=ID_DO_ATENDIMENTO` |

O mapa está em `model/rotas.php`; os arquivos de tela permitidos estão em `view/admin.php`. Um valor de `link` não reconhecido abre a visão geral, sem usar o conteúdo recebido como caminho de arquivo.

## Arquivos compartilhados

- `controller/sessao.php`: sessão, token CSRF e cabeçalhos HTTP.
- `controller/base.php`: método POST, validação de CSRF, tratamento de erros e redirecionamento após a operação.
- `controller/prepararDados.php`: instancia os DAOs e trata falha na conexão inicial.
- `model/entrada.php`: leitura de campos obrigatórios, inteiros e valores decimais.
- `persist/baseDAO.php`: execução preparada, consulta e controle de transações compartilhados.
- `view/funcoes.php`: escape HTML, formatação de datas e dinheiro, ícones e construção dos modais.
- `view/formularios.php`: inclui os arquivos de formulário.

Os caminhos usam `__DIR__` e respeitam maiúsculas e minúsculas, funcionando também em Linux. Identificadores são gerados pelo AUTO_INCREMENT do banco; não se usa `MAX(id)+1`. As operações de escrita usam POST, parâmetros preparados e token CSRF.
