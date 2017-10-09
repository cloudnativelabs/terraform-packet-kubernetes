output result {
  /* value = "${null_resource.result.triggers.split}" */
  value = "${local.result}"
}

locals {
  then_string = "${join(var.separator, var.then)}"
  else_string = "${join(var.separator, var.else)}"

  result_string = "${
    var.equality_condition_left == var.equality_condition_right
      ? local.then_string
      : local.else_string
  }"

  result = "${split(var.separator, local.result_string)}"
}
