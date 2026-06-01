class DiscoCatalog {
  static const List<DiscoOption> discos = [
    DiscoOption(
      id: 'lesco',
      name: 'LESCO',
      divisions: [
        DivisionOption(name: 'Lahore City', areas: ['Gulberg', 'Johar Town', 'Model Town', 'Garden Town']),
        DivisionOption(name: 'Cantt', areas: ['DHA Phase 1', 'DHA Phase 5', 'Bahria Town', 'Cantt Road']),
      ],
    ),
    DiscoOption(
      id: 'fesco',
      name: 'FESCO',
      divisions: [
        DivisionOption(name: 'Faisalabad', areas: ['Madina Town', 'People\'s Colony', 'Jaranwala Road', 'Gatwala']),
        DivisionOption(name: 'Jhang', areas: ['Satellite Town', 'Shorkot Road', 'Chenab Nagar', 'Bhowana']),
      ],
    ),
    DiscoOption(
      id: 'mepco',
      name: 'MEPCO',
      divisions: [
        DivisionOption(name: 'Multan', areas: ['Qasimpur Colony', 'Bosan Road', 'Hussain Agahi', 'Cantt']),
        DivisionOption(name: 'Bahawalpur', areas: ['Satellite Town', 'Model Town', 'Ahmedpur East', 'Yazman']),
      ],
    ),
    DiscoOption(
      id: 'pesco',
      name: 'PESCO',
      divisions: [
        DivisionOption(name: 'Peshawar', areas: ['University Road', 'Hayatabad', 'Gulbahar', 'Saddar']),
        DivisionOption(name: 'Mardan', areas: ['Cantt', 'Charsadda Road', 'Takht Bhai', 'Katlang']),
      ],
    ),
    DiscoOption(
      id: 'hesco',
      name: 'HESCO',
      divisions: [
        DivisionOption(name: 'Hyderabad', areas: ['Qasimabad', 'Latifabad', 'Saddar', 'Railway Colony']),
        DivisionOption(name: 'Sukkur', areas: ['Military Road', 'Barrage Road', 'Pano Aqil', 'Rohri']),
      ],
    ),
    DiscoOption(
      id: 'qesco',
      name: 'QESCO',
      divisions: [
        DivisionOption(name: 'Quetta', areas: ['Jinnah Town', 'Satellite Town', 'Sariab', 'Model Town']),
        DivisionOption(name: 'Khuzdar', areas: ['Moola', 'Kalat', 'Wadh', 'Surab']),
      ],
    ),
    DiscoOption(
      id: 'sepco',
      name: 'SEPCO',
      divisions: [
        DivisionOption(name: 'Sukkur', areas: ['New Sukkur', 'Old Sukkur', 'Airport Road', 'Shikarpur']),
        DivisionOption(name: 'Larkana', areas: ['Qambar', 'Ratodero', 'Badah', 'Naudero']),
      ],
    ),
    DiscoOption(
      id: 'iesco',
      name: 'IESCO',
      divisions: [
        DivisionOption(name: 'Islamabad', areas: ['F-6', 'F-7', 'G-10', 'I-8']),
        DivisionOption(name: 'Rawalpindi', areas: ['Satellite Town', 'Bahria Town', 'Wah Cantt', 'Gulistan Colony']),
      ],
    ),
  ];

  static DiscoOption? byId(String? discoId) {
    if (discoId == null) {
      return null;
    }
    for (final disco in discos) {
      if (disco.id == discoId) {
        return disco;
      }
    }
    return null;
  }
}

class DiscoOption {
  final String id;
  final String name;
  final List<DivisionOption> divisions;

  const DiscoOption({required this.id, required this.name, required this.divisions});
}

class DivisionOption {
  final String name;
  final List<String> areas;

  const DivisionOption({required this.name, required this.areas});
}
