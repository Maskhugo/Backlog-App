---
name: ship
description: Entrega uma mudança que já está implementada no working tree, do commit até o merge - cria feature branch, commita (via skill commit), dá push, abre PR no GitHub referenciando issues com "Closes #N", faz merge e confirma que as issues fecharam. Use quando o usuário pedir para abrir/gerar uma PR, "subir essa mudança", "mergear", ou "marcar a issue/as issues como concluída(s)" depois que o código já está pronto. Não use para implementar a issue do zero - isso fica fora do escopo, a skill assume que o diff já existe.
---

# Ship

Fluxo de entrega de uma mudança já implementada: branch → commit → push → PR → merge → fechamento de issues.

Pressupõe que o código já está pronto no working tree (staged ou não). Se ainda não há nada implementado, pare e pergunte o que codar primeiro — essa skill não escreve a feature.

## 1. Branch

- Rodar `git status` e `git branch --show-current`.
- Se a branch atual for `main`/`master`, criar uma feature branch **antes** de qualquer commit: `git checkout -b <nome-descritivo>` (kebab-case, prefixo `feat/`, `fix/` etc. conforme o tipo de mudança).
- Nunca commitar ou dar push direto em `main`/`master`.

## 2. Commit

Invocar a skill `commit` para staging + mensagem (Conventional Commits + trailer `Assisted-by: Claude Code <noreply@anthropic.com>`). Não duplicar essas regras aqui — a skill `commit` já cobre stage explícito, Regra dos Dois Chapéus, e o que fazer se o diff tiver segredo/PII.

## 3. Push

`git push -u origin <branch>`.

### Se falhar com 403 / "Permission denied"

Sinal de que a conta `gh` ativa não tem acesso a este repositório específico — comum quando há mais de uma conta logada (ex: pessoal vs. trabalho).

1. `gh auth status` para ver quais contas estão logadas em `github.com`.
2. Trocar para a conta com acesso ao repo: `gh auth switch --hostname github.com --user <conta>`.
3. Repetir o `git push`.
4. Guardar qual era a conta ativa original **antes** de trocar — no passo 6, depois do merge, trocar de volta para ela. A skill não deve deixar a conta ativa alterada como efeito colateral da entrega.

## 4. Pull Request

`gh pr create --title "..." --body "..."` com:

- Título curto no estilo Conventional Commits, refletindo a mudança principal.
- Corpo com resumo em bullets do que mudou, um "Test plan" se fizer sentido (testes/análise rodados), e o trailer `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
- Uma linha `Closes #N` para **cada** issue do GitHub relacionada — isso fecha a issue automaticamente quando a PR é mergeada no branch default, sem precisar fechar manualmente depois.
- Se os números das issues não estiverem claros pelo contexto da conversa, perguntar ao usuário ou buscar com `gh issue list` antes de criar a PR — nunca adivinhar números de issue.

## 5. Merge

Usar squash como padrão (`gh pr merge <n> --squash --delete-branch`) — mantém `main` com um commit por PR e remove a branch já consumida. Só usar outra estratégia (merge commit, rebase) se o usuário pedir ou se o histórico do repo mostrar uma convenção diferente já estabelecida.

## 6. Confirmar fechamento das issues

Verificar cada issue referenciada: `gh api repos/<owner>/<repo>/issues/<n> --jq '.state'` deve retornar `closed`. Se alguma não fechou (PR não foi para o branch default, ou o `Closes #N` não foi reconhecido), fechar manualmente com `gh issue close <n>`.

Se a conta `gh` foi trocada no passo 3, trocar de volta agora: `gh auth switch --hostname github.com --user <conta-original>`.

## 7. Sincronizar local

`git checkout main && git pull --ff-only`.

Arguments: $ARGUMENTS
