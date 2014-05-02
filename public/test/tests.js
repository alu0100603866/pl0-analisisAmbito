var assert = chai.assert;

suite('PL/0 Analyzer using Jison', function() {

  test('Asociaciatividad de la resta', function () {
    var result = pl0.parse('a=3-2-1.');
    assert.equal(result.content.right.left.value, 3);
    assert.equal(result.content.right.right.type, '-');
  });

  test('Asociaciatividad de la división', function () {
    var result = pl0.parse('a=3/2/1.');
    assert.equal(result.content.right.left.value, 3);
    assert.equal(result.content.right.right.type, '/');
  });

  test('Sentencia IF', function () {
    assert.equal(pl0.parse('if (a < b) then c = 3.').content.type, 'IF');
  });

  test('Sentencia IF-ELSE', function () {
    assert.equal(pl0.parse('if (a < b) then c = 3 else c = a.').content.type, 'IFELSE');
  });

  test('Dangling else', function () {
    var result = pl0.parse('if (a < b) then if (c != e) then a = a+1 else a = b.');
    assert.equal(result.content.type, 'IF');
    assert.equal(result.content.st.type, 'IFELSE');
  });

  test('PROCEDURE con parámetros', function () {
    var result = pl0.parse('procedure proc (a, b, c); c = a+b;.');
    assert.equal(result.proc_decls[0].type, 'PROCEDURE');
    assert.deepEqual(result.proc_decls[0].args, [
      {type: 'ARG', content: 'a'},
      {type: 'ARG', content: 'b'},
      {type: 'ARG', content: 'c'}
    ]);
  });

  test('CALL con parámetros', function () {
    var result = pl0.parse('call proc(2, c, 2*(b+c)).');
    assert.equal(result.content.type, 'PROC_CALL');
    assert.equal(result.content.arguments.length, 3);
    assert.equal(result.content.arguments[2].content.type, '*');
  });

  test('Errores en la entrada', function() {
    assert.throw(function() {
      pl0.parse('while (3 < 1) do if (a > b) then a=2-(2.'); // Falta el ')'
    });

    assert.throw(function() {
      pl0.parse('for (i = 0; i < 10; i++) do c +=i.'); // Esto no es PL/0...
    });

    assert.throw(function() {
      pl0.parse('begin a = b; b = c; c = d; d =; end.'); // Falta la asignació
    });
  });

});
