<?php
require_once __DIR__ . '/../model/UserModel.php';
require_once __DIR__ . '/../model/DoctorModel.php';
require_once __DIR__ . '/../model/PatientModel.php';
require_once __DIR__ . '/../model/AppointmentModel.php';
require_once __DIR__ . '/../model/ReportModel.php';
require_once __DIR__ . '/../model/AdminModel.php';
require_once __DIR__ . '/../includes/functions.php';

class AdminController {
    private $userModel;
    private $doctorModel;
    private $patientModel;
    private $appointmentModel;
    private $reportModel;
    private $adminModel;

    public function __construct() {
        $this->userModel = new UserModel();
        $this->doctorModel = new DoctorModel();
        $this->patientModel = new PatientModel();
        $this->appointmentModel = new AppointmentModel();
        $this->reportModel = new ReportModel();
        $this->adminModel = new AdminModel();
    }

    public function dashboardData() {
        return ['stats' => $this->reportModel->adminDashboard(), 'appointments' => $this->appointmentModel->todayAll()];
    }

    public function doctorsData() {
        return ['doctors' => $this->doctorModel->listDoctors(), 'specializations' => $this->doctorModel->listSpecializations()];
    }

    public function usersData() {
        return ['users' => $this->userModel->listUsers()];
    }

    public function reportsData() {
        return ['revenue' => $this->reportModel->revenueReport(), 'volume' => $this->reportModel->appointmentVolumeReport(), 'appointments' => $this->appointmentModel->all('', 0, '')];
    }

    public function addDoctor($post) {
        if ($this->userModel->findByEmail($post['email'])) {
            return 'Email already exists.';
        }
        $userId = $this->userModel->create($post['name'], $post['email'], $post['password'] ?: 'doctor123', $post['phone'] ?? '', 'doctor');
        $this->doctorModel->createDoctorProfile($userId, (int)$post['specialization_id'], $post['bio'] ?? '', (float)$post['consultation_fee'], '', $post['license_number'] ?? '', (int)$post['experience_years'], 1);
        return 'Doctor account created successfully.';
    }

    public function addReceptionist($post) {
        if ($this->userModel->findByEmail($post['email'])) {
            return 'Email already exists.';
        }
        $this->userModel->create($post['name'], $post['email'], $post['password'] ?: 'reception123', $post['phone'] ?? '', 'receptionist');
        return 'Receptionist account created successfully.';
    }

    public function addSpecialization($post) {
        $this->adminModel->addSpecialization($post['name'], $post['description'] ?? '');
        return 'Specialization saved.';
    }
}
?>
