while(($children = $(':not(.section)>.span_1_of_3:lt(3)')).length) {
    $children.wrapAll($('<div class="section group"></div>'));
}
