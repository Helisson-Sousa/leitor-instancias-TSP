# 🔎 Projeto: Branch and Bound e Best Bound

Este repositório contém duas implementações em **Julia** para problemas de otimização:

- **Branch and Bound (B&B)** → implementação clássica.  
- **Best Bound (BB)** → variação do B&B que expande sempre o nó com o melhor limite.  

---

## 📂 Estrutura do repositório

As implementações estão separadas em **branches**:

- `main` → contém o código do **Branch and Bound**.  
- `best-bound` → contém o código do **Best Bound**.  

Para alternar entre as branches localmente:

```bash
# Branch com Branch and Bound
git checkout main

# Branch com Best Bound
git checkout best-bound

⚙️ Como executar

Instale as dependências necessárias no Julia (ex.: JuMP, GLPK):

using Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")


Rode o código principal:

julia main.jl

🎯 Objetivo acadêmico

Este projeto foi desenvolvido na linguagem Julia para a disciplina [nome da disciplina], com o objetivo de implementar e comparar os métodos Branch and Bound e Best Bound.

📊 Resultados (exemplo de tabela)
Instância	B&B (segundos)	BB (segundos)	Melhor desempenho
exemplo1	1.25	0.98	BB
exemplo2	3.47	3.62	B&B
exemplo3	7.81	5.12	BB