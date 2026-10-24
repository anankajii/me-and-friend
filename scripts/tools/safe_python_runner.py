"""Restricted Python runner used by the in-game coding challenge.

It accepts only a small, educational subset of Python. The submitted source is
parsed first and every AST node is whitelisted before compilation. In
particular, imports, attributes, indexing, functions, classes, loops, files,
and arbitrary calls are rejected. The only callable name is print().
"""

from __future__ import annotations

import ast
import json
import sys


MAX_SOURCE_CHARS = 2_000
MAX_OUTPUT_CHARS = 500
MAX_LITERAL_CHARS = 300


class ValidationError(Exception):
    pass


class SafeAstValidator(ast.NodeVisitor):
    """Allow assignments, conditions, expressions, and calls to print only."""

    def visit_Module(self, node: ast.Module) -> None:
        for statement in node.body:
            self.visit(statement)

    def visit_Assign(self, node: ast.Assign) -> None:
        if len(node.targets) != 1 or not isinstance(node.targets[0], ast.Name):
            raise ValidationError("Variabel harus ditulis sederhana, misalnya: pesan = 'Halo'.")
        self._validate_name(node.targets[0].id)
        if node.targets[0].id == "print":
            raise ValidationError("Nama print tidak boleh diganti.")
        self.visit(node.value)

    def visit_Expr(self, node: ast.Expr) -> None:
        self.visit(node.value)

    def visit_If(self, node: ast.If) -> None:
        self.visit(node.test)
        for statement in node.body:
            self.visit(statement)
        for statement in node.orelse:
            self.visit(statement)

    def visit_Call(self, node: ast.Call) -> None:
        if not isinstance(node.func, ast.Name) or node.func.id != "print":
            raise ValidationError("Hanya fungsi print() yang dapat dipakai di tantangan ini.")
        for argument in node.args:
            self.visit(argument)
        for keyword in node.keywords:
            if keyword.arg not in {"sep", "end"}:
                raise ValidationError("print() hanya mendukung argumen sep dan end.")
            self.visit(keyword.value)

    def visit_Name(self, node: ast.Name) -> None:
        self._validate_name(node.id)

    def visit_Constant(self, node: ast.Constant) -> None:
        if not isinstance(node.value, (str, int, float, bool, type(None))):
            raise ValidationError("Tipe data ini belum diizinkan.")
        if isinstance(node.value, str) and len(node.value) > MAX_LITERAL_CHARS:
            raise ValidationError("Teks terlalu panjang.")
        if isinstance(node.value, int) and len(str(node.value)) > 64:
            raise ValidationError("Angka terlalu besar.")

    def visit_BinOp(self, node: ast.BinOp) -> None:
        if not isinstance(node.op, (ast.Add, ast.Sub, ast.Div, ast.Mod)):
            raise ValidationError("Operator yang diizinkan: +, -, /, dan %.")
        self.visit(node.left)
        self.visit(node.right)

    def visit_UnaryOp(self, node: ast.UnaryOp) -> None:
        if not isinstance(node.op, (ast.USub, ast.UAdd, ast.Not)):
            raise ValidationError("Operator tersebut belum diizinkan.")
        self.visit(node.operand)

    def visit_Compare(self, node: ast.Compare) -> None:
        if not all(isinstance(operator, (ast.Eq, ast.NotEq, ast.Lt, ast.LtE, ast.Gt, ast.GtE)) for operator in node.ops):
            raise ValidationError("Perbandingan tersebut belum diizinkan.")
        self.visit(node.left)
        for comparator in node.comparators:
            self.visit(comparator)

    def visit_BoolOp(self, node: ast.BoolOp) -> None:
        if not isinstance(node.op, (ast.And, ast.Or)):
            raise ValidationError("Operator boolean tersebut belum diizinkan.")
        for value in node.values:
            self.visit(value)

    def generic_visit(self, node: ast.AST) -> None:
        raise ValidationError("'%s' tidak diizinkan pada editor tantangan ini." % type(node).__name__)

    @staticmethod
    def _validate_name(name: str) -> None:
        if name.startswith("_") or name == "__builtins__":
            raise ValidationError("Nama variabel tersebut tidak diizinkan.")


def run_source(source: str) -> dict[str, object]:
    if not source.strip():
        raise ValidationError("Tulis kode Python terlebih dahulu.")
    if len(source) > MAX_SOURCE_CHARS:
        raise ValidationError("Kode terlalu panjang untuk tantangan ini.")

    try:
        tree = ast.parse(source, mode="exec")
    except SyntaxError as error:
        raise ValidationError("SyntaxError baris %d: %s" % (error.lineno or 1, error.msg)) from error

    SafeAstValidator().visit(tree)
    output_parts: list[str] = []

    def safe_print(*values: object, sep: str = " ", end: str = "\n") -> None:
        if not isinstance(sep, str) or not isinstance(end, str):
            raise ValidationError("sep dan end pada print() harus berupa teks.")
        text = sep.join(str(value) for value in values) + end
        if sum(len(part) for part in output_parts) + len(text) > MAX_OUTPUT_CHARS:
            raise ValidationError("Output terlalu panjang.")
        output_parts.append(text)

    sandbox = {"__builtins__": {}, "print": safe_print}
    try:
        exec(compile(tree, "<jawaban-pemain>", "exec"), sandbox, sandbox)
    except ValidationError:
        raise
    except Exception as error:  # Tetap kirim error Python yang ramah untuk belajar.
        raise ValidationError("%s: %s" % (type(error).__name__, error)) from error
    return {"ok": True, "output": "".join(output_parts).removesuffix("\n")}


def main() -> int:
    try:
        if len(sys.argv) not in {2, 3}:
            raise ValidationError("Runner membutuhkan berkas kode dan hasil opsional.")
        with open(sys.argv[1], "r", encoding="utf-8") as source_file:
            result = run_source(source_file.read())
    except ValidationError as error:
        result = {"ok": False, "message": str(error)}
    except Exception:
        result = {"ok": False, "message": "Runner Python gagal dijalankan."}
    serialized = json.dumps(result, ensure_ascii=False)
    if len(sys.argv) == 3:
        with open(sys.argv[2], "w", encoding="utf-8") as result_file:
            result_file.write(serialized)
    else:
        print(serialized)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
