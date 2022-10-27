  window.addEventListener("load", init);
  var footprint_area = parseFloat(0);
  var footprint_perimeter = parseFloat(0);
  var footing_num = parseFloat(0);

  function setPerimeter(data) {
    footprint_perimeter = (parseFloat(data)).toFixed(2);
  }

  function setBaseSize(data) {
    footprint_area = (parseFloat(data)).toFixed(2);
  }

  function init() {
    items = qsa(".assembly");
    for( i=0; i<items.length; i++) {
      items[i].className += " hidden";
    }
    id("find_cost").addEventListener("click",showResults);
    sketchup.apply_asb();
  }

  function showResults() {
    items = qsa(".form-check-input");
    for( i=0; i<items.length; i++) {
      items[i].addEventListener("change",changeVisibility);
      // changeVisibility.bind(items[i])();
    }
    setQTOValue();
    calcCostPerDiv();
    AttInputObserver();
  }

  function AttInputObserver() {
    items = qsa("div[class^='division'] input");
    for( i=0; i<items.length; i++) {
      items[i].addEventListener("change",removeTotal);
    }
  }

  function removeTotal() {
    nodes = qsa(".div_total");
    nodes.forEach(node => {
      if (node != null) {
      node.parentNode.removeChild(node);
      }
    })
    qs(".sum").classList.add("hidden");
  }

  function setQTOValue() {
    inputs = qsa('input:not([class = "form-check-input"]');
    for( i=0; i<inputs.length; i++) {
      if (inputs[i].className == "footprint_area") {
        let num = inputs[i].value;
        let boo = num == "";
        // let boo2 = typeof inputs[i].value == 'undefined';
        if (num == "") {
          inputs[i].value = parseFloat(footprint_area);
        } else{
          footprint_area = inputs[i].value;
        }
      } else if (inputs[i].className == "footprint_perimeter"){
        let num = inputs[i].value;
        if (num == "") {
          inputs[i].value = parseFloat(footprint_perimeter);
        } else {
          footprint_perimeter = inputs[i].value;
        }
      } else if (inputs[i].className == "footing_number"){
        let num = inputs[i].value;
        let boo = num == "";
        // let boo2 = typeof inputs[i].value == 'undefined';
        if (num == "") {
          inputs[i].value = parseFloat(10);
        } else{
          footing_num = inputs[i].value;
        }
      }
    }
    calcF_sw();
  }

  function calcF_sw() {
    sketchup.log("hello");
    let swQuantity = id('f_sw_input').value;
    if (swQuantity == '') {
      updateSwArea();
    }
    id('fd_height').addEventListener('change',updateSwArea);
    id('fd_perimeter').addEventListener('change',updateSwArea);
  }

  function updateSwArea() {
    let num1 = id('fd_height').value;
    swQuantity = parseFloat(num1) * footprint_perimeter;
    sketchup.log(swQuantity);
    id('f_sw_input').value = swQuantity;
  }

  function calcCostPerDiv() {
    let arr = ['fd','f_','fr'];
    let p_cost = 0;
    arr.forEach(divName => {
      items = qsa("input[name^=" + divName + "][class='form-check-input']");
      sketchup.log("items number: " + items.length);
      let divFdTotal = parseFloat(0);
      for( i=0; i<items.length; i++) {
        if (items[i].checked) {
          let s_i = items[i].value + "_input";
          let s_p = items[i].value + "_p";
          let num = parseFloat(id(s_i).value);
          sketchup.log(num);
          let price = parseFloat(id(s_p).value);
          sketchup.log(price);
          divFdTotal = parseFloat(divFdTotal) + parseFloat(num*price);
          let y = divFdTotal.toFixed(2);
          divFdTotal = y;
          sketchup.log(divFdTotal);
        }
      }
      p_cost += parseFloat(divFdTotal);
      let newNode = gen("h1");
      let s = "Cost of this division " + formatCost(divFdTotal) + "$";
      let s2 = 'cost ${divFdTotal}';
      newNode.textContent = s;
      let newSection = gen("section");
      newSection.appendChild(newNode);
      let r_element = qs("div[id=" + divName + "] article section[class='div_total']");
      newSection.className = "div_total";
      if (r_element != null) {
        qs("div[id=" + divName + "] article").replaceChild(newSection,r_element);
      } else {
        qs("div[id=" + divName + "] article").appendChild(newSection);
      }
    })
    let sum = "Total project cost: " + formatCost(p_cost) + "$";
    sumNode = qs(".sum");
    sumNode.textContent = sum;
    sumNode.classList.remove("hidden");
  }

  function changeVisibility() {
    let bool = id("summary").classList.contains("active");
    if (!bool) {
      if (this.checked) {
        let name = this.value;
        id(this.value).classList.remove("hidden");
      } else {
        id(this.value).classList.add("hidden");
      };
    }
  };

  function openDiv(evt, divID) {
    qsa(".division").forEach( division => {
      division.classList.add("hidden");
    })
    id(divID).classList.remove("hidden");

    items = qsa("div[id^=" + divID + "] .form-check-input");
    for( i=0; i<items.length; i++) {
      showAssembly.bind(items[i])();
    }
    // sketchup.log(qsa("div[id^=" + divID + "] .assembly"));
    qsa(".tablinks").forEach(tab => {
      tab.classList.remove("active");
    })
    evt.currentTarget.classList.add("active");
  }

  function showAssembly() {
    if (this.checked) {
      id(this.value).classList.remove("hidden");
    }
  }

  function openAll(evt, divID) {
    qsa(".division").forEach( division => {
      division.classList.remove("hidden");
    })
    qsa(".assembly").forEach( section => {
      section.classList.add("hidden");
    })
    qsa(".tablinks").forEach(tab => {
      tab.classList.remove("active");
    })
    evt.currentTarget.classList.add("active");
  }

  function formatCost(data){
    num = Math.round(data*100)/100;
    cost_formated = num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    return cost_formated;
  }

  /**
   * Returns the element that has the ID attribute with the specified value.
   * @param {string} idName - element ID
   * @returns {object} DOM object associated with id.
   */
  function id(idName) {
    return document.getElementById(idName);
  }

  /**
   * Returns the first element that matches the given CSS selector.
   * @param {string} selector - CSS query selector.
   * @returns {object} The first DOM object matching the query.
   */
  function qs(selector) {
    return document.querySelector(selector);
  }

  /**
   * Returns the array of elements that match the given CSS selector.
   * @param {string} selector - CSS query selector
   * @returns {object[]} array of DOM objects matching the query.
   */
  function qsa(selector) {
    return document.querySelectorAll(selector);
  }

  /**
   * Returns a new element with the given tag name.
   * @param {string} tagName - HTML tag name for new DOM element.
   * @returns {object} New DOM object for given HTML tag.
   */
  function gen(tagName) {
    return document.createElement(tagName);
  }