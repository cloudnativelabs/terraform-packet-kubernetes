output result {
  value = "${local.result}"
}

locals {
  then_string = "${join(var.separator, var.then)}"
  else_string = "${join(var.separator, var.else)}"

  result_string = "${
    var.if == var.equals
      ? local.then_string
      : local.else_string
  }"

  result = "${compact(split(var.separator, local.result_string))}"
}
