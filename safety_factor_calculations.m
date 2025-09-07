%% Safety Factor Analysis 

% Consider this material for all components : Aluminum 6061 (Heat Treated)

Sy = 276 * 10^(6); % Pa Aluminum's Yield Strength
UTS = 310 * 10^(6); % Pa Aluminum's Ultimate Tensile Strength
Sf_unadjusted = 124 * 10^(6); % Pa, Unajusted Endurance Limit from equation 6.5 in book

%% Component 1: Static Failure of Hand Crank
 
F = 1; % N 
% distance from critical point of max bending to force location
dis = 0.018; % m 
Max_Moment = F*dis; % N*m 
r_shaft_handle = 5 * 10^(-3); % m
l_crank = 30.23*10^(-3); % overall length of crank in m
I_circular = pi*(r_shaft_handle^4)/4; % m^4
Bending_Stress_crank = (-Max_Moment*r_shaft_handle)/I_circular;

% Since Uniaxial Tension, we get: 

sf_comp1 = abs(Sy/Bending_Stress_crank); % safety_factor

fprintf('\n%s\n','==== Component 1: Static Failure of Hand Crank ====');
fprintf("The Maximum Bending Stress for the crank is: %.3f Pascals \n",Bending_Stress_crank)
fprintf("The safety factor for the crank is:          %.3f \n",sf_comp1)

if sf_comp1 < 1.5
    warning("Component 1 may fail under load: safety factor = %.2f", sf_comp1);
end

%% Component 1: Fatigue Failure of Hand Crank

% --- Inputs ---
F = 1;                          % N (crank force)
dis = 0.018;                    % m (moment arm)
r_shaft_handle = 5e-3;          % m (shaft radius)

% --- Geometry & Bending Moment ---
Max_Moment = F * dis;           % N·m
I = pi * r_shaft_handle^4 / 4;  % m^4

% --- Bending Stress Amplitude (fully reversed) ---
sigma_alt = abs( Max_Moment * r_shaft_handle / I );  % Pa (My/I)
sigma_mean = 0;                                       % Pa (assumed)

% --- Endurance Limit & Modification Factors ---
d = 2 * r_shaft_handle;                    % m
d_inch = d / 0.0254;                       % convert to inches

Ca = 1;                                    % surface finish
Cb = 0.869*(2*d_inch)^(-0.097);            % size factor 
Cc = 1;                                    % load factor (bending)
Cd = 1;                                    % temperature factor
Ce = 0.702;                                % reliability (99.9%)

% Adjusted endurance limit
S_fe = Sf_unadjusted * Ca * Cb * Cc * Cd * Ce;         % Pa

% --- Fatigue Safety Factor (simple amplitude ratio) ---
Nf = S_fe / sigma_alt;

% (Optional) Goodman correction if I had a nonzero mean stress:
% UTS = 310e6;  % Pa (given)
% Nf_goodman = 1 / ( sigma_alt/S_fe + sigma_mean/UTS );

% --- Output ---
fprintf('\n%s\n','==== Component 1: Fatigue Failure of Hand Crank ====');
fprintf('Alternating bending stress of the Hand Crank is:   %.2f MPa\n', sigma_alt/1e6);
fprintf('Adjusted endurance limit S_e of the Hand Crank is: %.2f MPa\n', S_fe/1e6);
fprintf('Fatigue safety factor (Nf) of the Hand Crank is:   %.2f\n', Nf);
% fprintf('Goodman fatigue safety factor: %.2f\n', Nf_goodman);


%% Component 2: Static Failure of the Hinge 

% Consider the weight of the hinge negligible 
w_door = 8.98*10^-3*9.81; % weight of door in Newtons
dis = 25.4*10^(-3); % distance from critical point to force location in m

Max_Moment_hinge = w_door*dis/4; % N*m from Appendix B
r_shaft_hinge = 2.47 * 10^(-3); % m
I_circular_hinge = pi*(r_shaft_hinge^4)/4; % m^4
Bending_Stress_hinge = (-Max_Moment_hinge*r_shaft_hinge)/I_circular_hinge;

% Since Uniaxial Tension, we get: 

sf_comp2 = abs(Sy/Bending_Stress_hinge); % safety_factor

fprintf('\n%s\n','==== Component 2: Static Failure of Hinge ====');
fprintf("The Maximum Bending Stress for the hinge is: %.3f Pascals \n",Bending_Stress_hinge)
fprintf("The safety factor for the hinge is:          %.3f \n",sf_comp2)

if sf_comp2 < 1.5
    warning("Component 2 may fail under static load: safety factor = %.2f", sf_comp2);
end


%% Component 3: ASME Fatigue Safety Factor (Nf) for Shaft Design

% Fatigue failure was considered as it is more likely to fail compared to
% static loading in the shaft

% Inputs: Use SI Units
d = 9.525* 10^(-3) ;         % Shaft diameter (m)
Kf = 1 ;                     % Fatigue stress concentration factor
l_shaft = 0.2 ;              % Length of the Shaft
w_system = 115.5*10^(-3) ;   % Weight of the system, including claw + chocolacolate + connector
w_shaft =  57*10^(-3) ;      % Weight of the shaft
Ma = (w_shaft+w_system)*l_shaft/4;    % Alternating moment (Nm)
Tm = 1*l_crank ;             % Mean torque (Nm), input given from 1 N force from crank * the crank length 

% Adjusted Fatigue Strength Analysis (S_fat) Using C-Factors

% C-factors (from notes or assumptions)
Ca = 1;                       % Surface finish factor
Cb = 0.869*(3/8)^(-0.097);    % Size factor
Cc = 1;                       % Load factor (Bending Nominates)
Cd = 1;                       % Temperature factor
Ce = 0.702;                   % Reliability factor

% Adjusted endurance limit
S_fat = Sf_unadjusted * Ca * Cb * Cc * Cd * Ce ; % For 5*10^8 cycles 

% Output
fprintf("Adjusted Fatigue Strength (S_fat): %.2f Pa\n", S_fat / 1e6);

% Intermediate terms
sigma_a = 32*Kf*Ma/(pi*d^3);    % bending amplitude
tau_m   = 16*Tm   /(pi*d^3);    % steady torsion
sigma_eq = sqrt( sigma_a^2 + 3*tau_m^2 );

% Safety factor calculation
Nf = S_fat / sigma_eq;

% Output
fprintf('\n%s\n','==== Component 3: ASME Fatigue (Shaft) ====');
fprintf('  σ_a (bending)      : %10.2f MPa\n', (32*Kf*Ma/(pi*d^3))/1e6);
fprintf('  τ_m (torsion)      : %10.2f MPa\n', (16*Tm/(pi*d^3))/1e6);
fprintf('  S_e (endurance)    : %10.2f MPa\n', S_fat/1e6);
fprintf('  Fatigue SF         : %10.2f\n', Nf);

%% Component 4: Hinge Bolts Thread Stripping Failure 

% Considering our current scenario, from the 3 forms of failure methods,
% the most likely to occur is thread stripping. Therefore, this section
% considers the bolt failure analysis by Thread Stripping. 


% Inputs (use actual values)
F = w_door ;                           % N, total shear force on the joint 
d_bolt = 8 *10^-3;                     % m, bolt diameter (M8 bolt)
d_minor_bolt = 6.647 *10^-3;           % m, bolt's minor diameter
l_contact = 6.5  *10^-3;                  % m, length of the bolt
thread_pitch = 1.25  *10^-3;           % m, Thread Pitch
n_thr_contact = l_contact/thread_pitch;   % Number of Threads in contact
n_bolts = 2;                           % Number of bolts

% Cross-sectional area of bolt (shear area)
A_bolt = 2*pi*(d_minor_bolt/2)*thread_pitch*n_thr_contact;

% Shear stress
tau = F / (n_bolts * A_bolt);  % Shear stress per bolt

Ssy_al = 0.577 * Sy; 
% Safety Factor
sf_shear = Ssy_al / tau;

% Output
fprintf('\n%s\n','==== Component 4: Thread‑Stripping of Hinge Bolts ====');
fprintf("Bolt diameter:                  %.2f mm\n", d_bolt * 1000);
fprintf("Shear force per bolt:           %.5f N\n", F / n_bolts);
fprintf("Shear stress per bolt:          %.5f MPa\n", tau / 1e6);
fprintf("Shear yield strength (Al 6061): %.2f MPa\n", Ssy_al / 1e6);
fprintf("Safety factor of the Bolt is:   %.2f\n", sf_shear);
fprintf('\n%s\n','==== End of Safety‑Factor Calculations ====');