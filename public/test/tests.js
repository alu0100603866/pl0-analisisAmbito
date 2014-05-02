var assert = chai.assert;

suite('PL/0 Analizador using Jison', function() {

  test('Resta', function () {
    var result = pl0.parse('var a; a=3-2-1.');
    assert.equal(result.content.right.left.left.value, 3);
    assert.equal(result.content.right.left.right.value, 2);
    assert.equal(result.content.right.left.type, '-');
  });

  test('División', function () {
    var result = pl0.parse('var a; a=3/2/1.');
    assert.equal(result.content.right.left.left.value, 3);
    assert.equal(result.content.right.left.right.value, 2);
    assert.equal(result.content.right.left.type, '/');
  });

  test('IF', function () {
    assert.equal(pl0.parse('var a, b, c; if (a < b) then c = 3.').content.type, 'IF');
  });

  test('IF-ELSE', function () {
    assert.equal(pl0.parse('var a, b, c; if (a < b) then c = 3 else c = a.').content.type, 'IFELSE');
  });

  test('if then (if then (else)))', function () {
    var result = pl0.parse('var a, b, c, e; if (a < b) then if (c != e) then a = a+1 else a = b.');
    assert.equal(result.content.type, 'IF');
    assert.equal(result.content.st.type, 'IFELSE');
  });

  test('PROCEDURE(parametro)', function () {
    var result = pl0.parse('procedure proc (a, b, c); c = a+b;.');
    assert.equal(result.procs[0].type, 'PROCEDURE');
    assert.equal(result.procs[0].name, 'proc');
    assert.deepEqual(result.procs[0].args, [
      {type: 'ARG', name: 'a'},
      {type: 'ARG', name: 'b'},
      {type: 'ARG', name: 'c'}
    ]);
  });

  test('CALL con parámetros', function () {
    var result = pl0.parse('procedure proc(a,b,c); call proc(2, c, 2*(b+c));.');
    assert.equal(result.procs[0].content.type, 'PROC_CALL');
    assert.equal(result.procs[0].content.arguments.length, 3);
    assert.equal(result.procs[0].content.arguments[2].content.type, '*');
  });

});

suite('PL/0 Analizador ambito Jison', function() {
    test('Tabla de símbolos', function() {
        var result = pl0.parse('const a = 5; var b; procedure c; call c; b = a+7.');
        assert.deepEqual(result.sym_table, {
            a: {
                type: "CONST VAR",
                value: "5",
                declared_in: "global"
            },
            b: {
                type: "VAR",
                declared_in: "global"
            },
            c: {
                type: "PROCEDURE",
                arglist_size: 0,
                declared_in: "global"
            }
        });
    });
      
      test('declared_in asociado a la más cercana', function() {
        var result = pl0.parse('var a; procedure b(a); call b(a-5); a = a+3.');
        assert.equal(result.sym_table.a.declared_in, 'global');
        assert.equal(result.procs[0].sym_table.a.declared_in, 'b');
    });
      
    test('Valor a constantes', function () {
        assert.throw(function() {
            pl0.parse('const a = 12; a = a+3.');
        });
    });
      
    test('Paso de parámetros erroneo', function () {
        assert.throw(function() {
            pl0.parse('procedure proc (a, b, c); a = b+c; call proc (1, 2).');
        });
    });
      
    test('Errores', function() {
        assert.throw(function() {
            pl0.parse('var a, b; while (3 < 1) do if (a > b) then a=2-(2.');
        });
           
        assert.throw(function() {
            pl0.parse('var i, c; for (i = 0; i < 10; i++) do c +=i.');
        });
           
        assert.throw(function() {
            pl0.parse('var a, b, c, d; begin a = b; b = c; c = d; d =; end.');
        });
    });

});
