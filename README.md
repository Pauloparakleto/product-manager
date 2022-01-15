# Projeto ProductManager

O objetivo deste mini projeto é implementar tarefas adicionais à api restfull deste repositório, que consiste em gerenciar o catálogo de produtos de um e-commerce.

### Tarefas:
1. Adicionar paginação a api de produtos
com o valor padrão de 20 itens por página, podendo ser alterado via parâmetros até o máximo de 100

2. Permitir ordenar por qualquer uma das colunas de forma crescente ou decrescente

3. Permitir filtrar por qualquer uma das colunas, podendo usar todas as comparações possíveis (contém, igual, diferente, maior, maior ou igual, menor...)

4. Criar endpoint de produtos relacionados, em uma relação de n..n com produto, onde um produto pode ter um ou mais produtos relacionados, sendo necessário validar que um produto não pode ser linkado a ele próprio. a api permitirá adicionar e remover relações de produtos

   `POST /products/:product_id/related_products`
   ```json
   // request body
   {
     "related_product_id": 22
   }
   ```

   ```json
   // response body, status: 201
   {
     "id": 22,
     "name": "Product test",
     "price": "10.99"
   }
   ```

   ```json
   // response body, status: 404|422
   {
     "errors": ["Mensagem de erro"]
   }
   ```

   `DELETE /products/:product_id/related_products/:related_product_id`

   ```json
   // response body, status: 204
   null
   ```

   ```json
   // response body, status: 404
   {
     "errors": ["Mensagem de erro"]
   }
   ```
5. Adicionar produtos relacionados ao json do produto apenas no endpoint de detalhes do produto, ficando no formato abaixo:
   ```json
    // response body, status: 200
    {
      "id": 1,
      "name": "Product test",
      "description": "Description of product test",
      "price": "10.99",
      "quantity": 50,
      "created_at": "2021-07-05T23:13:17.383Z",
      "created_at": "2021-07-05T23:13:17.383Z",
      "related_prooducts": [
        {
          "id": 22,
          "name": "Product test",
          "price": "10.99"
        }
      ]
    }

6. Atualizar a documentação com as alterações nos endpoints existentes e os novos

OBS:
- Nas tarefas 2 e 3 pode ser usado uma gem para facilitar o trabalho
- Já existem specs para o código atual, o candidato deverá adaptalas as mudanças solicitadas e adicionar novas quando necessário.

### Documentação detalhada da API
Devido ao número elevado de exemplos de requisições, moveu-se a documentação para um local mais apropriado.

Os detalhes para que o time do frontend possa implementar mais rapidamente algumas lógicas estão lá.

- [Postman product manager workspace](https://www.postman.com/squada-mentoria/workspace/product-manager/overview)

## Rodando o projeto:

Requisitos:
  - Ruby 3.0.1
  - Rails 6.1.4
  - Postgresql

Comandos:

```bash
git clone https://github.com/Hendel-Tecnologia/teste_vaga_rails.git
```

```bash
cd teste_vaga_rails
```

```bash
bundle install
```

```bash
rails db:create db:migrate db:seed
```

Rodando os testes:
```bash
rspec -f doc
```