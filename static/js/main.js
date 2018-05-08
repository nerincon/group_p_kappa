let drivers = 1;
let cars = 1;
let vresult=[];
// M.AutoInit();
// var instance = M.Tabs.init('.tabs', );

function materialize() {
    $('.modal').modal();    
    $(".datepicker").datepicker({
        yearRange: 90
    });
    $("select").formSelect();
    $(".tabs").tabs({});

    $(".tooltipped").tooltip();
    $(".sidenav").sidenav();

    $("input[type=radio][name=currently_insured]").click(function () {
        if ($("input[type=radio][name=currently_insured]:checked").val() === "No") {
            jQuery("#pop").hide();
        } else {
            jQuery("#pop").show();
        }
    });

    $("select[name=coverage]").change(function () {
        if ($("select[name=coverage][id=selects_field]").val() == "liability") {
            jQuery("#full_cover").hide();
        } else {
            jQuery("#full_cover").show();
        }
    });

    $("input[type=radio][name=tickets_accidents]").click(function () {
        if ($("input[type=radio][name=tickets_accidents]:checked").val() == "No") {
            jQuery("#accidents").hide();
        } else {
            jQuery("#accidents").show();
        }
        
    });

    $('input.counter').characterCounter();


}
// 1N4AL3AP6DN452526
function verify_vin(vin){
    vresult; 
    $.ajax({
        url: "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVINValuesBatch/",
        type: "POST",
        data: { format: "json", data: vin},
        dataType: "json",
        success: function(result)
        {
            vresult = result;
            if (vresult.Message == "No data found" || vresult.Results[0].ErrorCode.indexOf("0") != 0 ){
                // alert(vresult.Results[0].ErrorCode)
                // console.log(vresult.Results[0].ErrorCode)
                $("#error_msg").html(`${vresult.Results[0].ErrorCode}`);
                $("#modal1").modal('open')
                return 0;
            }else{
          console.log(result);
          $(`#brand${drivers}`).val($(`#brand${drivers}`).val() + vresult.Results[0].Make);
          $(`#year${drivers}`).val($(`#year${drivers}`).val() + vresult.Results[0].ModelYear);
          $(`#model${drivers}`).val($(`#model${drivers}`).val() + vresult.Results[0].Model);
            }

        },
        error: function(xhr, ajaxOptions, thrownError)
        {
            console.log(xhr.status);
            console.log(thrownError);
        }
    });
}


$(window).on("load", function () {
   
    $("#verify_vin").on("click", function () {
    
        verify_vin(document.getElementById(`VIN${drivers}`).value);
        
    });

    materialize();


    $("#add_btn").on("click", function () {

        drivers += 1;
        
        $(
            `<li class="tab"><a href="#driver${drivers}"> driver ${drivers}</a> </li>`
        ).insertBefore("#add_li");
        $(`<div id="driver${drivers}" style='display:block'; class="active">
    <!-- driver ${drivers} Tabs-->
<h5 class="center-align">Driver ${drivers} information</h5>
<!-- <h6 class="center-align">Additional driver info</h6> -->
<div class="row">
    <div class="input field col s6 offset-m3 m3">
        <input name="first_name${drivers}" id="first_name${drivers}" type="text" class="validate">
        <label for="first_name${drivers}">First Name</label>
    </div>

    <div class="input field col s6  m3">
        <input name="last_name${drivers}" id="last_name${drivers}" type="text" class="validate">
        <label for="last_name${drivers}">Last Name</label>
    </div>
</div>
<div class="row">
    <div class="input field col s12 offset-m3 m6">
        <input name="occupation${drivers}" id="occupation${drivers}" type="text">
        <label for="occupation${drivers}">Occupation</label>
    </div></div>

<div class="divider"></div>
<div class="row">
    <div class="col s6 offset-m3 m3">

        <p>
            <label>
                <input class="with-gap" name="gender${drivers}" type="radio" value="male" checked />
                <span>Male</span>
            </label>
        </p>
        <p>
            <label>
                <input class="with-gap" name="gender${drivers}" type="radio" value="female" />
                <span>Female</span>
            </label>
        </p>
    </div>
    <div class="col s6 m3">
        <p>
            <label>
                <input class="with-gap" name="marital_status${drivers}" type="radio" value="single" checked />
                <span>Single</span>
            </label>
        </p>
        <p>
            <label>
                <input class="with-gap" name="marital_status${drivers}" type="radio" value="Married" />
                <span>Married</span>
            </label>
        </p>

    </div>

</div>
<div class="divider"></div>
<div class="row">

    <div class="col s6 offset-m3 m3">
        <label for="birthdate${drivers}" class>birthdate</label>
        <input name="birthdate${drivers}" id="birthdate${drivers}" type="text" class="datepicker">


    </div>

    <div class=" input-field col s6 m3">
        <select name="relation${drivers}" id='relation${drivers}'>
            <option  value="self" >Self</option>
            <option class="flow-text" value="spouse" selected>Spouse/common law</option>
            <option value="sibiling">Sibiling</option>
            <option value="parent">Parent</option>
            <option value="child">Child</option>
            <option value="other">Other</option>
        </select>
        <label>Relation to primary driver:</label>
    </div>
</div>

<div class="row">
    <div class=" input-field col s6 offset-m3 m3">
        <select name="id_type${drivers}" id="id_type${drivers}">
            <option value="Tx DL" selected>Texas Drivers License</option>
            <option value="Tx ID">Texas ID</option>
            <option value="Out of state">Out of state</option>
            <option value="passport">Passport</option>
            <option value="matricula">Matricula</option>
            <option value="International DL">International Drivers License</option>
            <option value="no ID">No ID</option>
        </select>
        <label>Form of ID (Choose one):</label>
    </div>
    <div class="input field col s6 m3">
        <label for="ID_No${drivers}">ID Number</label>
        <input name="id_no${drivers}" id="ID_No${drivers}" type="text" class="validate counter" data-length="20">

    </div>

</div>

<h5 class="center-align">Accidents or Tickets?</h5>
<h6 class="center-align">Please be honest. Your record will be verified. You may get a disclousre discount</h6>
<br>
<br> Any accidents or tickets in the past 5 years: &nbsp;&nbsp;&nbsp;

<label>
    <input class="with-gap" name="tickets_accidents${drivers}" type="radio" value="Yes" />
    <span>Yes</span>
</label>

<label>
    <input class="with-gap" name="tickets_accidents${drivers}" type="radio" value="No" checked/>
    <span>No</span>
</label>

<div class="optional" id="accidents${drivers}">
    <span class="level">
        <div class="wrapper">
            <span class="tooltip"></span>
            <br>
            <span class="c1">How many tickets have you had in the past 3 years?</span>
            <span class="c2">
                <input type="number" min="0" max="4" value="0" name="ticekts${drivers}">
            </span>

        </div>
    </span>

    <span class="level">
        <div class="wrapper">
            <span class="tooltip"></span>
            <br>
            <span class="c1">How many accidents have you had in the past 3 years?</span>
            <span class="c2">
                <input type="number" min="0" max="4" value="0" name="accidents${drivers}">
            </span>
            <br>
            <br> were any of these accidents at fault?
            <label>
                <input class="with-gap" name="at_fault${drivers}" type="radio" value="Yes" />
                <span>Yes</span>
            </label>

            <label>
                <input class="with-gap" name="at_fault${drivers}" type="radio" value="No" checked/>
                <span>No</span>
            </label>
            <br>
            <br>
        </div>
    </span>

</div>
    
    </div>`).insertBefore("#add_div");


    $(`input[type=radio][name=tickets_accidents${drivers}]`).click(function () {
        if ($(`input[type=radio][name=tickets_accidents${drivers}]:checked`).val() == "No") {
            jQuery(`#accidents${drivers}`).hide();
        } else {
            jQuery(`#accidents${drivers}`).show();
        }
    });

   
        materialize();
       
        
        setTimeout(function () {
          $("#driver_tabs li.tab a")[`${drivers - 1}`].click()
          $(`#driver${drivers-1}`).css('display', 'none')
          $(`#driver${drivers-1}`).removeClass('active')
        //   $(`#driver${drivers}`).addClass('active')
        }, 100);

       

    });

    $("#add_car_btn").on("click", function () {

        cars += 1;
        $(
            `<li class="tab"><a href="#vehicle${cars}"> vehicle ${cars}</a> </li>`
        ).insertBefore("#add_car_li");
        $(`<div id="vehicle${cars}" style='display:block'; class="active">
    <!-- vehicle ${cars} Tabs-->
      <div id="vehicle${cars}">
                <h5 class="center-align" class="fs-title">Vehicle ${cars}</h5>
                <h6 class="center-align" class="fs-subtitle">What Vehicle are we insuring today?</h6>
                <div class="row">
                    <div class="input field col s3 offset-m3 m3">
                        <input type="text" id="VIN${cars}" name="VIN${cars}" placeholder="(VIN) Vehicle Identification Number"   class="counter" data-length="17" required />
                        <label for="VIN${cars}">(VIN) Vehicle Identification Number</label>
                    </div>
                    <div class="col s3 offset-m1 m3">
                        <a class="btn waves-effect waves-light" name="verify_vin" id="verify_vin" >verify VIN
                        </a>
                    </div>
                  
                </div>
                <div class="row">
                    <div class="input field col s3 offset-m1 m3">
                        <input type="text" name="year${cars}" placeholder="year" />
                    </div>
                    <div class="input field col s3 ">
                        <input type="text" name="brand${cars}" placeholder="brand" />
                    </div>
                    <div class="input field col s3 ">
                        <input type="text" name="model${cars}" placeholder="model" />
                    </div>
                </div>


                <div id="coverages${cars}">
                    <h5 class="center-align">Coverage</h5>
                    <h6 class="center-align">How much coverage do you want?</h6>
                    <div class="row">
                        <span id="selects">Desired coverage:
                            <br>
                            <select name="coverage${cars}" id="selects_field">
                                <option value="liability">Liability Only</option>
                                <option value="full_coverage">Comprihensive/Collision(Full Coverage)</option>
                            </select>
                        </span>
                    </div>
                    <div class="optional" id="full_cover${cars}">
                        <span id="selects">Desired Deductible:
                            <br>
                            <select name="deductible${cars}" id="selects_field">
                                <option value="500">$500.00</option>
                                <option value="1000">$1,000.00</option>
                            </select>
                        </span>

                        <div style="text-align:left">
                            <br>
                            <h5 class="center-align">Additional coverage:</h5>
                            <br>
                            <label>
                                <input type="checkbox" name="PIP${cars}" value="PIP">
                                <span>Personal Injury Protection (PIP)</span>
                            </label>
                            <br>
                            <label>
                                <input type="checkbox" name="UM${cars}" value="UM">
                                <span>Uninsured Motorist</span>
                            </label>
                            <br>
                            <label>
                                <input type="checkbox" name="RENTAL${cars}" value="Rental">
                                <span>Rental</span>
                            </label>
                            <br>
                            <label>
                                <input type="checkbox" name="Towing${cars}" value="Towing">
                                <span>Towing</span>
                            </label>
                        </div>
                    </div>


                </div>
            </div>
        </div>

    </div>`).insertBefore("#add_car");

    $(`select[name=coverage${cars}]`).change(function () {
        if ($(`select[name=coverage${cars}][id=selects_field]`).val() == "liability") {
            jQuery(`#full_cover${cars}`).hide();
        } else {
            jQuery(`#full_cover${cars}`).show();
        }
    });

        materialize();
        setTimeout(function () {
          $("#cars_tabs li.tab a")[`${cars - 1}`].click()
          $(`#vehicle${cars-1}`).css('display', 'none')
          $(`#vehicle${cars-1}`).removeClass('active')
        //   $(`#vehicle${cars}`).addClass('active')
        }, 100);

    });

});



var driver = [
    "first_name",
    "last_name",
    "cell_phone",
    "email",
    "gender",
    "marital_status",
    "birthdate",
    "relation",
    "form_id",
    "id_no"
];
