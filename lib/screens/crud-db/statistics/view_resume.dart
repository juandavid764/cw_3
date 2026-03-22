import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:mr_croc/widgets/chartPie.dart';
import 'package:mr_croc/database/db_functions.dart';
import 'package:mr_croc/provider/provider_notifier.dart';

class ResumeView extends StatefulWidget {
  const ResumeView({super.key});

  @override
  State<ResumeView> createState() => _ResumeViewState();
}

class _ResumeViewState extends State<ResumeView> {
  int _valorNetoWidget = 0;
  String _fechaTextWidget = '';
  int _costumerQuantityWidget = 0;
  String _besHourWidget = '';
  Map<String, double> _datos = {'sin ventas': 0};
  String _bestProduct = 'Producto';
  bool _isMonthly = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SwitchListTile(
              title: const Text('Ver por mes'),
              value: _isMonthly,
              onChanged: (value) {
                setState(() {
                  _isMonthly = value;
                  _fechaTextWidget = '';
                  _valorNetoWidget = 0;
                  _costumerQuantityWidget = 0;
                  _besHourWidget = '';
                  _datos = {'sin ventas': 0};
                  _bestProduct = 'Producto';
                });
              },
            ),
            _buttonCaledar(),
            const SizedBox(height: 10),
            _valorNetoCard(),
            const SizedBox(height: 10),
            _bestProductCard(),
            const SizedBox(height: 10),
            _horaPicoCostumerCard(screenWidth),
            const SizedBox(height: 20),
            _chartPieCard(),
          ],
        ),
      ),
    );
  }

  void _getValueText(List<DateTime?> values) async {
    values = values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();
    var valueText = (values.isNotEmpty ? values[0] : null);
    String finalValueText;
    if (_isMonthly) {
      finalValueText = '${valueText!.year}-${valueText.month}';
    } else {
      finalValueText = '${valueText!.year}-${valueText.month}-${valueText.day}';
    }

    List<int> dateIds = await getDateIds(finalValueText, _isMonthly);

    int valorNetoUpdate = 0;
    int costumerQuantityupdate = 0;
    String bestHour = '';

    await Future.wait([
      getNetValue(dateIds).then((v) => valorNetoUpdate = v),
      getQuantityCostumers(dateIds).then((v) => costumerQuantityupdate = v),
      getBestHour(dateIds).then((v) => bestHour = v),
      getProductsSales(dateIds),
    ]);

    if (bestHour.isNotEmpty) {
      bestHour = '$bestHour - ${int.parse(bestHour) + 1}';
    }

    setState(() {
      _valorNetoWidget = valorNetoUpdate;
      _fechaTextWidget = finalValueText;
      _costumerQuantityWidget = costumerQuantityupdate;
      _besHourWidget = bestHour;
      _datos = pdtStadictsList.value;
      _bestProduct = productoMasVendido();
    });
  }

  String productoMasVendido() {
    String productoMasVendido = '';
    double maxVentas = double.negativeInfinity;

    _datos.forEach((producto, ventas) {
      if (ventas > maxVentas) {
        maxVentas = ventas;
        productoMasVendido = producto;
      }
    });

    return productoMasVendido;
  }

  Widget _buttonCaledar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Selecciona ${_isMonthly ? 'el mes' : 'la fecha'} a consultar',
          icon: const Icon(Icons.calendar_month, color: Colors.amberAccent),
          onPressed: () async {
            if (_isMonthly) {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (selectedDate != null) {
                _getValueText([selectedDate]);
              }
            } else {
              final values = await showCalendarDatePicker2Dialog(
                dialogSize: const Size(325, 400),
                context: context,
                config: CalendarDatePicker2WithActionButtonsConfig(
                  calendarType: CalendarDatePicker2Type.single,
                  selectedDayHighlightColor: Colors.amberAccent,
                  closeDialogOnCancelTapped: true,
                ),
                value: [DateTime.now()],
                dialogBackgroundColor: Colors.black26,
              );
              if (values != null) {
                _getValueText(values);
              }
            }
          },
        ),
        Text('${_isMonthly ? 'Mes' : 'Día'}: $_fechaTextWidget', style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _valorNetoCard() {
    var formatear = NumberFormat.simpleCurrency(decimalDigits: 0);

    return Card(
      color: const Color.fromARGB(100, 53, 66, 72),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.attach_money_rounded,
                color: Color.fromRGBO(76, 175, 80, 1), size: 50),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ventas Netas',
                    style: TextStyle(color: Colors.white60, fontSize: 15)),
                Text(formatear.format(_valorNetoWidget),
                    style: const TextStyle(color: Colors.white, fontSize: 25)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bestProductCard() {
    return Card(
      color: const Color.fromARGB(100, 53, 66, 72),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.star,
                color: Color.fromRGBO(255, 235, 59, 1), size: 50),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mejor Producto',
                    style: TextStyle(color: Colors.white60, fontSize: 15)),
                Text(_bestProduct,
                    style: const TextStyle(color: Colors.white, fontSize: 25)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _horaPicoCostumerCard(double screenWidth) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _infoCard(
          icon: Icons.group,
          color: const Color.fromRGBO(244, 67, 54, 1),
          title: 'Clientes',
          value: '$_costumerQuantityWidget',
        ),
        _infoCard(
          icon: Icons.safety_check,
          color: const Color.fromRGBO(33, 150, 243, 1),
          title: 'Hora Pico',
          value: _besHourWidget,
        ),
      ],
    );
  }

  Widget _infoCard(
      {required IconData icon,
      required Color color,
      required String title,
      required String value}) {
    return SizedBox(
      width: 160,
      child: Card(
        color: const Color.fromARGB(100, 53, 66, 72),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 12)),
                  Text(value,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chartPieCard() {
    return Card(
      color: const Color.fromARGB(255, 30, 34, 33),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ChartPieWidget(dataMap: _datos),
      ),
    );
  }
}