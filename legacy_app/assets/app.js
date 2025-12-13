var app = new Vue({
  el: "#app",
  data: {
    message: "Version beta",
    alert: {
      type: "success",
      show: false,
      message: "TEST test",
    },
    db: [],
    viewAddPage: false,
    viewAddGroup: false,
    viewAddEmployer: false,
    viewAddDepartment: false,
    viewEmployeesList: false,
    viewDepartmentList: false,
    selectPage: false,
    selectGroup: {
      number: 1,
      days: 31,
    },
    editObj: false,
    blockAddGroup: false,
    formPage: {
      id: false,
      title: "",
    },
    formEmploeyee: {
      id: false,
      did: false,
      name: "",
      surname: "",
    },
    formDepartment: {
      id: false,
      name: "",
      min_percent: 1.2,
      max_percent: 4
    },
    formGroup: {
      number: false,
      name: "",
      days: false,
      departments: [],
    },
    groups: [
      {
        number: 1,
        name: "Январь",
        days: 31,
      },
      {
        number: 2,
        name: "Февраль",
        days: 29,
      },
      {
        number: 3,
        name: "Март",
        days: 31,
      },
      {
        number: 4,
        name: "Апрель",
        days: 30,
      },
      {
        number: 5,
        name: "Май",
        days: 31,
      },
      {
        number: 6,
        name: "Июнь",
        days: 30,
      },
      {
        number: 7,
        name: "Июль",
        days: 31,
      },
      {
        number: 8,
        name: "Август",
        days: 31,
      },
      {
        number: 9,
        name: "Сентябрь",
        days: 30,
      },
      {
        number: 10,
        name: "Октябрь",
        days: 31,
      },
      {
        number: 11,
        name: "Ноябрь",
        days: 30,
      },
      {
        number: 12,
        name: "Декабрь",
        days: 31,
      },
    ],
  },
  created() {
    if (this.db.length < 1) {
      let obj = {
        pages: [],
        departments: [],
        employees: [],
      };

      this.db = { ...obj };
    }
  },
  methods: {
    calcEmployeeZp(department) {
      department.employees.forEach((emp) => {
        emp.zp = 0;

        for (let i = 0; i < department.items.length; i++) {
          if (department.items[i].employees.includes(emp.id)) {
            emp.zp += parseFloat(department.items[i].zp);
          }
        }

        emp.zp = emp.zp.toFixed(2);
      });
    },
    calcSumm(department) {
      department.fact_summ = 0;
      for (let i = 0; i < department.items.length; i++) {
        department.fact_summ += department.items[i].fact;
      }
    },
    calcPlanDays(dep) {
      console.log(dep);
      let day_plan = dep.plan_summ / dep.items.length;
      for (let i = 0; i < dep.items.length; i++) {
        dep.items[i].plan = day_plan.toFixed(2);
      }
    },
    calcZP(item, manual = false, department = false) {
      let check = 0;

      if (item.fact && item.fact != 0) {
        item.fact =
          typeof item.fact === "string"
            ? parseFloat(item.fact.replace(/[^\d+]/g, ""))
            : item.fact;
        check++;
      }

      if (check === 1) {
        if (!manual) {
          if(!department.min_percent) department.min_percent = 1.2;
          if(!department.max_percent) department.max_percent = 4;
          this.calcPercent(item, department);
        }
        if (item.employees.length > 0) {
          item.zp =
            ((parseFloat(item.fact) / 100) * item.percent) /
            item.employees.length;
          item.zp = item.zp.toFixed(2);
        }

        if (department) {
          this.calcEmployeeZp(department);
          this.calcSumm(department);
        }
      } else {
        //this.callAlert('warning', 'Ошибка расчета. Проверьте значения ПЛАН и ФАКТ. Пример: 1 или 1.00')
      }
    },
    calcPercent(item, department) {
      if (item.plan - 1000 > item.fact) {

        item.percent = department.min_percent;
      } else {
        item.percent = department.max_percent;
      }
    },
    callAlert(type, message) {
      this.alert.type = type;
      this.alert.message = message;
      this.alert.show = true;

      setTimeout(() => {
        this.alert.show = false;
      }, 4000);
    },
    checkEmploeyeInItem(uid, data) {
      if (data.employees.includes(uid)) {
        return true;
      } else {
        return false;
      }
    },
    changeItemEmploeye(uid, data, dep = false) {
      if (data.employees.includes(uid)) {
        data.employees = data.employees.filter((el) => el !== uid);
      } else {
        data.employees.push(uid);
      }
      this.calcZP(data, true, dep);
    },
    selectDepartmentForGroup(group) {
      this.editObj = group;
      this.viewDepartmentList = true;
    },
    deleteDepartment(dep) {
      this.db.departments = this.db.departments.filter(
        (el) => el.id !== dep.id
      );
    },
    deleteDepartmentFromGroup(group, id) {
      group.departments = group.departments.filter((el) => el.id !== id);
    },
    addDepartmentToGroup(dep) {
      let check = this.editObj.departments.filter((el) => el.id === dep.id);
      if (check && check.length > 0) {
        this.callAlert("warning", "Данный отдел уже существует в группе!");
        return false;
      } else {
        let obj = {
          id: dep.id,
          name: dep.name,
          min_percent: dep.min_percent ? dep.min_percent : 1.2,
          max_percent: dep.max_percent ? dep.max_percent : 4,
          fact_summ: 0,
          plan_summ: 0,
          difference_summ: 0,
          employees: [],
          items: [],
        };

        for (let i = 0; i < this.editObj.days; i++) {
          let item = {
            number: i + 1,
            plan: 0,
            fact: "",
            percent: 0,
            zp: 0,
            employees: [],
          };

          obj.items.push(item);
        }

        let employees_list = this.db.employees.filter(
          (el) => el.did === obj.id
        );
        if (employees_list) {
          obj.employees = employees_list;
        }

        this.editObj.departments.push(obj);
      }
    },
    closeDepartmentList() {
      this.editObj = false;
      this.viewDepartmentList = false;
    },
    createPeriod() {
      if (!this.selectPage) {
        alert("Выбирите страницу для добавления РП");
        return false;
      } else {
        this.checkGroup();
        this.viewAddGroup = true;
      }
    },
    addNewGroup() {
      let obj = { ...this.formGroup };
      let find_month = this.groups.find(
        (el) => el.number === this.selectGroup.number
      );
      if (find_month) {
        obj.number = find_month.number;
        obj.name = find_month.name;
        obj.days =
          this.selectGroup.days > 0 ? this.selectGroup.days : find_month.days;
        this.selectPage?.groups
          ? this.selectPage.groups.push(obj)
          : (this.selectPage.groups = [obj]);
        this.viewAddGroup = false;
      }
    },
    addNewDepartment() {
      if (!this.formDepartment.name || this.formDepartment.name.length < 1) {
        alert("Введите название отдела");
        return false;
      }

      let check = this.db.departments.filter(
        (el) => el.name === this.formDepartment.name
      );
      if (check.length < 1) {
        this.formDepartment.id = this.generateId();
        let obj = { ...this.formDepartment };
        this.db.departments.push(obj);
        this.viewAddDepartment = false;
      } else {
        alert("Отдел с таким название существет!");
        return false;
      }
    },
    deleteEmployee(emp) {
      this.db.employees = this.db.employees.filter((el) => el.id !== emp.id);
    },
    addNewEmployee() {
      if (!this.formEmploeyee.name || this.formEmploeyee.name.length < 1) {
        this.callAlert("danger", "Введите Имя сотрудника");
        return false;
      }
      if (
        !this.formEmploeyee.surname ||
        this.formEmploeyee.surname.length < 1
      ) {
        this.callAlert("danger", "Введите Фамилию сотрудника");
        return false;
      }
      if (!this.formEmploeyee.did) {
        this.callAlert("danger", "Выбирите отдел для сотрудника.");
        return false;
      }

      this.formEmploeyee.id = this.generateId();
      let obj = { ...this.formEmploeyee };
      this.db.employees.push(obj);
      this.viewAddEmployer = false;
      this.callAlert(
        "success",
        `Сотрудник -  ${this.formEmploeyee.surname} ${this.formEmploeyee.name} успешно добавлен`
      );
      this.formEmploeyee.id = false;
      this.formEmploeyee.did = false;
      this.formEmploeyee.name = "";
      this.formEmploeyee.surname = "";
    },
    checkGroup() {
      if (this.selectPage.groups) {
        let obj = this.selectPage.groups.filter(
          (el) => el.number === this.selectGroup.number
        );
        if (obj && obj.length > 0) {
          this.blockAddGroup = true;
        } else {
          this.blockAddGroup = false;
          let month = this.groups.find(
            (el) => el.number === this.selectGroup.number
          );
          if (month) {
            this.selectGroup.days = month.days;
          } else {
            this.selectGroup.days = 0;
          }
        }
      }
    },
    addNewPage() {
      if (!this.formPage.title || this.formPage.title.length < 1) {
        alert("Введите название страницы");
        return false;
      }

      let check = this.db.pages.filter(
        (el) => el.title === this.formPage.title
      );
      if (check.length < 1) {
        this.formPage.id = this.generateId();
        let obj = { ...this.formPage };
        this.db.pages.push(obj);
        this.selectPage = obj;
        this.viewAddPage = false;
      } else {
        alert("Страница с таким название существует!");
      }
    },
    funcSelectPage(id) {
      let obj = this.db.pages.filter((el) => el.id === id);
      if (obj.length > 0) {
        this.selectPage = obj[0];
      } else {
        alert("Не удалось найти страницу в базе!");
        return false;
      }
    },
    differenceSumm(arg1, arg2){
      let diff = arg1 - arg2;
      return diff.toFixed(1);
    },
    serializePercent(dep){
      if(dep.min_percent >= dep.max_percent) dep.max_percent = Number(dep.min_percent) + 0.1;
    },
    loadDB(event) {
      new Promise((res, rej) => {
        let fileReader = new FileReader();
        fileReader.onload = function () {
          res(JSON.parse(fileReader.result));
        };
        fileReader.readAsText(event.target.files[0]);
      }).then((res) => {
        if (res) {
          this.db = res;
          this.selectPage = this.db.pages[0];
          console.log(this.db)
        } else {
          alert("Не удалось прочитать файл!");
        }
      });
    },
    saveDB() {
      let link = document.createElement("a");

      let today = new Date();

      // получить сегодняшнюю дату в формате `MM/DD/YYYY`
      let now = today.toLocaleDateString("en-US");
      now = now.replace("/", "_");

      link.download = `db-${now}.json`;
      console.log(JSON.stringify(this.db));
      let blob = new Blob([JSON.stringify(this.db)], {
        type: "application/json",
      });

      link.href = URL.createObjectURL(blob);

      link.click();
      this.callAlert("success", "База сохранена!");
    },
    generateId() {
      return Math.random().toString(16).slice(2);
    },
  },
});
